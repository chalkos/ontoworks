class OntologiesController < ApplicationController
  include OntologiesHelper

  # raise an exception if authorize has not yet been called
  after_action :verify_authorized
  before_action :set_ontology, only: [:show, :edit, :update, :destroy, :download, :change_code, :logs]

  # GET /ontologies
  # GET /ontologies.json
  def index
    @my_ontologies = Ontology.where(user_id: current_user.id) if user_signed_in?
    @public_ontologies = Ontology.eager_load(:user).where(public: true)
    authorize Ontology

    respond_to do |format|
      format.html
      format.json  { render json: @public_ontologies }
      format.xml
    end
  end

  # GET /ontologies/1
  # GET /ontologies/1.json
  def show
    authorize_present @ontology

    if user_owns_ontology(@ontology)
      @logs = Log.where(ontology: @ontology.id).order(created_at: :desc).first(10)
    else
      @logs = Log.where(ontology: @ontology.id, msg_type: Log.visitor_types).order(created_at: :desc).first(10)
    end

    respond_to do |format|
      format.html
      format.json  { render json: @ontology }
      format.xml
    end
  end

  # GET /ontologies/new
  def new
    @ontology = Ontology.new
    authorize @ontology
  end

  # GET /ontologies/1/edit
  def edit
    authorize_present @ontology
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

        Hash(model.getNsPrefixMap()).each_pair do |name, uri|
          @ontology.prefixes.build(name: name, uri: uri)
        end
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
        @ontology.add_default_queries! Query

        log = Log.new(ontology_id: @ontology.id)
        log.ontologycreate!
        log.save

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
    authorize_present @ontology
    desc = @ontology.desc
    pub = @ontology.public
    sha = @ontology.shared

    respond_to do |format|
      if @ontology.update(ontology_params.slice(:desc, :public, :shared))
        #Log changes
        if(desc != @ontology.desc)
          log = Log.new(ontology_id: @ontology.id)
          log.updatedesc!; log.save
        end
        if(pub != @ontology.public)
          log = Log.new(ontology_id: @ontology.id, helper: @ontology.public)
          log.updatepublic!; log.save
        end
        if(sha != @ontology.shared)
          log = Log.new(ontology_id: @ontology.id,helper: @ontology.shared)
          log.updateshared!; log.save
        end
        #respond
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
    authorize_present @ontology

    Query.delete_all(ontology_id: @ontology.id)
    dir = @ontology.tdb_dir
    @ontology.destroy

    require 'fileutils'
    FileUtils.rm_r dir

    @ontology.destroy
    respond_to do |format|
      format.html { redirect_to ontologies_url, notice: 'Ontology was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def logs
    authorize_present @ontology
    if user_owns_ontology(@ontology)
      @logs = Log.where(ontology: @ontology.id).order(created_at: :desc)
    else
      @logs = Log.where(ontology: @ontology.id, msg_type: Log.visitor_types).order(created_at: :desc)
    end
  end

  # GET /ontologies/1/download
  def download
    authorize_present @ontology

    @type, ext = download_defs(params)
    onto_data = write_ontology @type

    friendly_name = name_file(@ontology.name, ext)

    if params[:download][:with] == "no"
      send_data onto_data, :filename => friendly_name, :type =>"text/plain"
    else
      zip_ontology_data(friendly_name,onto_data, @ontology.queries)
    end
  end

  # GET /ontologies/1/change_code
  def change_code
    log = Log.new(ontology_id: @ontology.id)
    log.codechange!
    log.from_code = @ontology.code

    authorize_present @ontology
    old_location = @ontology.tdb_dir
    generate_code! @ontology

    log.to_code = @ontology.code
    log.save
    require 'fileutils'
    FileUtils.mv(old_location, @ontology.tdb_dir)

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

    out = StringIO.new
    model.write(out.to_outputstream, out_format)
    dataset.end()

    return out.string
  end

  def zip_ontology_data(friendly_name, onto_data, queries)
    require 'zip'

    zipio = Zip::OutputStream.write_buffer do |zip|
      zip.put_next_entry friendly_name
      zip.write onto_data

      queries.each do |query|
        zip.put_next_entry name_query(query)
        zip.write description(query)
      end
    end

    zipio.rewind
    binary_data = zipio.sysread
    send_data binary_data, :filename => "#{friendly_name}.zip", :type => "application/zip"
  end

  def generate_code!(ontology)
    # ensure unique code
    inc = 0
    loop do
      ontology.code = Digest::MD5.hexdigest "#{ontology.hash}#{inc}#{Time.now.to_f}"
      break if Ontology.where(:code => ontology.code).empty?
      inc += 1
    end
  end
end
