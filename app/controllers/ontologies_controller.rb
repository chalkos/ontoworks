class OntologiesController < ApplicationController
  include OntologiesHelper

  # raise an exception if authorize has not yet been called
  after_action :verify_authorized
  before_action :set_ontology, only: [:show, :edit, :update, :destroy, :download, :change_code]

  # GET /ontologies
  # GET /ontologies.json
  def index
    @ontologies = Ontology.eager_load(:user).all
    @my_ontologies = @ontologies.where(user_id: current_user.id) if user_signed_in?
    @public_ontologies = @ontologies.where.not(user_id: current_user.id) if user_signed_in?
    authorize @ontologies
  end

  # GET /ontologies/1
  # GET /ontologies/1.json
  def show
    authorize @ontology
  end

  # GET /ontologies/new
  def new
    @ontology = Ontology.new
    authorize @ontology
  end

  # GET /ontologies/1/edit
  def edit
    authorize @ontology
  end

  # POST /ontologies
  # POST /ontologies.json

  def create
    require 'digest/md5'
    require 'rubygems/package'
    require 'zlib'
    require 'zip'

    @ontology = Ontology.new(ontology_params)
    @ontology.user_id = current_user.id if user_signed_in?

    authorize @ontology

    generate_code! @ontology

    if @ontology.valid?
      ## UNZIP START, IF NECESSARY
      case validate_file(@ontology.file)
      when :gz # if the file is in the gzip format
        tar_extract = Gem::Package::TarReader.new(Zlib::GzipReader.open(@ontology.file.path))
        tar_extract.rewind # The extract has to be rewinded after every iteration
        tar_extract.each do |entry|
          @file = File.join('tmp/extracted/', @ontology.code+entry.full_name)
          FileUtils.mkdir_p(File.dirname(@file))
          File.open(@file, 'w') {|file| file.write(entry.read.force_encoding('UTF-8'))}
        end
        tar_extract.close
      when :zip # if the file is in the zip format
        Zip::File.open(@ontology.file.path) do |zip_file|
          zip_file.each do |entry|
            @file = File.join('tmp/extracted/', @ontology.code+entry.name)
            FileUtils.mkdir_p(File.dirname(@file))
            zip_file.extract(entry, @file)
          end
        end
      else :xml # if the ontology is xml or one of its subtypes
        @file = @ontology.file.path
      end

      ## JENA START
      require 'jena_jruby'

      FileUtils.mkdir_p(@ontology.tdb_dir) unless File.directory?(@ontology.tdb_dir)

      dataset = Jena::TDB::TDBFactory.createDataset(@ontology.tdb_dir)

      dataset.begin(Jena::Query::ReadWrite::WRITE)
      model = dataset.getDefaultModel()

      #open the ontology
      input = Jena::Util::FileManager.get().open(@file)

      #read the RDF/XML file
      begin
        model.read(input, nil)
      rescue Exception => e
        @ontology.errors.add(:file, "An error occurred while importing the ontology: " + e.to_s)
        FileUtils.remove_dir(@ontology.tdb_dir)
      end
      ## JENA END

      input.close()
      dataset.commit()
      dataset.end()

      # remove extracted/temporary file
      File.delete(@file)
    end

    respond_to do |format|
      if @ontology.errors.empty? && @ontology.save
        format.html { redirect_to @ontology, notice: 'Ontology was successfully created.' }
        format.json { render :show, status: :created, location: @ontology }
      else
        format.html { render :new }
        format.json { render json: @ontology.errors, status: :unprocessable_entity }
      end
    end
  end


  # PATCH/PUT /ontologies/1
  # PATCH/PUT /ontologies/1.json
  def update
    authorize @ontology
    respond_to do |format|
      if @ontology.update(ontology_params.slice(:desc, :public, :shared))
        format.html { redirect_to @ontology, notice: 'Ontology was successfully updated.' }
        format.json { render :show, status: :ok, location: @ontology }
      else
        format.html { render :edit }
        format.json { render json: @ontology.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ontologies/1
  # DELETE /ontologies/1.json
  def destroy
    require 'fileutils'
    FileUtils.rm_r @ontology.tdb_dir

    @ontology.destroy
    respond_to do |format|
      format.html { redirect_to ontologies_url, notice: 'Ontology was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /ontologies/1/download
  def download
    authorize @ontology

    @type = params[:type]
    case @type
    when "TURTLE"; ext = ".ttl"
    when "RDF/JSON"; ext = ".json"
    when "N-TRIPLES"; ext = ".nt"
    when "RDF/XML-ABBREV"; ext= ".rdf"
    else
      ext = ".rdf"
      @type = "RDF/XML-ABBREV"
    end
    friendly_name = @ontology.name.gsub(/[^\w\s_-]+/, '').gsub(/(^|\b\s)\s+($|\s?\b)/, '\\1\\2').gsub(/\s+/, '_') + ext

    name = write_ontology @type
    file = File.open(name, "r")
    send_data file.read, :filename => friendly_name, :type =>"text/plain"
    FileUtils.rm(name)
  end

  # GET /ontologies/1/change_code
  def change_code
    authorize @ontology
    generate_code! @ontology
    # also change the TDB directory

    respond_to do |format|
      if @ontology.save
        format.html { redirect_to @ontology, notice: 'Ontology code was successfully changed.' }
        format.json { render :show, status: :ok, location: @ontology }
      else
        format.html { render :show }
        format.json { render json: @ontology.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_ontology
    @ontology = Ontology.eager_load(:user).where(code: params[:code]).first
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def ontology_params
    params.require(:ontology).permit(:name, :desc, :public, :shared, :file)
  end

  # Create string with content of an ontology
  def write_ontology(out_format)
    require 'jena_jruby'
    dataset = Jena::TDB::TDBFactory.createDataset(@ontology.tdb_dir)
    dataset.begin(Jena::Query::ReadWrite::READ)
    model = dataset.getDefaultModel()

    #create filename with timestamp to minimise same filename problems
    tmpName = @ontology.name + "_" + Time.now.utc.iso8601
    tmpName = tmpName.gsub(/[^\w\s_-]+/, '').gsub(/(^|\b\s)\s+($|\s?\b)/, '\\1\\2').gsub(/\s+/, '_')
    tmpName = "tmp/" + tmpName

    bw = java.io.BufferedWriter.new(java.io.FileWriter.new(tmpName))
    model.write(bw, out_format)

    bw.close
    dataset.end()
    tmpName
  end

  def generate_code!(ontology)
    # ensure unique code
    inc = 0
    loop do
      ontology.code = Digest::MD5.hexdigest (ontology.hash+inc).to_s
      break if Ontology.where(:code => ontology.code).empty?
      inc += 1
    end
  end
end
