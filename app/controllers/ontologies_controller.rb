class OntologiesController < ApplicationController
  before_action :set_ontology, only: [:show, :edit, :update, :destroy]

  # GET /ontologies
  # GET /ontologies.json
  def index
    @ontologies = Ontology.all
  end

  # GET /ontologies/1
  # GET /ontologies/1.json
  def show
  end

  # GET /ontologies/new
  def new
    @ontology = Ontology.new
  end

  # GET /ontologies/1/edit
  def edit
  end

  # POST /ontologies
  # POST /ontologies.json

  def create
    require 'digest/md5'

    @ontology = Ontology.new(ontology_params.except :file)

    # ensure unique code
    inc = 0
    loop do
      @ontology.code = Digest::MD5.hexdigest (@ontology.hash+inc).to_s
      break if Ontology.where(:code => @ontology.code).empty?
      inc += 1
    end

    # validate required fields
    if(params[:ontology]['name'] == "")
      notify_and_back("Name can not be blank.")
      return
    end

    @file = params[:ontology]['file']
    if(@file.nil?)
      notify_and_back("A file must be submitted.")
      return
    end

    ## UNZIP START, IF NECESSARY

    case validate_file(@file)
    when :gz # if the file is in the gzip format
      require 'rubygems/package'
      require 'zlib'
      tar_extract = Gem::Package::TarReader.new(Zlib::GzipReader.open(@file.path))
      tar_extract.rewind # The extract has to be rewinded after every iteration
      size = 0
      tar_extract.each do |entry|
        if size == 0 # on the first file: extract it to the tmp folder
          @file = File.join('tmp/extracted/', @ontology.code+entry.full_name)
          FileUtils.mkdir_p(File.dirname(@file))
          File.open(@file, 'w') {|file| file.write(entry.read.force_encoding('UTF-8'))}
          size += 1
        else # on the second file
          File.delete(@file) # remove extracted/temporary file
          notify_and_back("The uploaded package must contain a single file.")
          return
        end
      end
      tar_extract.close
    when :zip # if the file is in the zip format
      require 'zip'
      size = 0;
      Zip::File.open(@file.path) do |zip_file|
        zip_file.each do |entry|
          if size == 0 # on the first file: extract it to the tmp folder
            @file = File.join('tmp/extracted/', @ontology.code+entry.name)
            FileUtils.mkdir_p(File.dirname(@file))
            zip_file.extract(entry, @file)
            size += 1;
          else #on the second file
            File.delete(@file) # remove extracted/temporary file
            notify_and_back("The uploaded package must contain a single file.")
            return
          end
        end
      end
    when :xml # if the ontology is xml or one of its subtypes
      @file = params[:ontology]['file'].path
    else
      notify_and_back("Invalid file type. Valid formats are xml, zip and tar.gz.")
      return
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
      input.close();
      File.delete(@file)
      notify_and_back("An error occurred while importing the ontology: " + e);
      return;
    end

    #model.write(java.lang.System::out, "N-TRIPLE")

    input.close()
    dataset.commit()
    dataset.end()
    ## JENA END

    # remove extracted/temporary file
    File.delete(@file)

    respond_to do |format|
      if @ontology.save
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
    respond_to do |format|
      if @ontology.update(ontology_params.slice(:desc))
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

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_ontology
    @ontology = Ontology.where(code: params[:code]).first
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def ontology_params
    params.require(:ontology).permit(:name, :desc, :unlisted, :extendable, :expires, :file)
  end

  def validate_file(file)
    type = file.content_type
    if type == "application/gzip"
      :gz
    elsif type == "application/zip"
      :zip
    elsif type.include? "xml"
      :xml
    else
      :other
    end
  end

  def notify_and_back(note)
    flash.now[:notice] = note
    #redirect_to :back
    respond_to do |format|
      format.html { render :new }
      format.json { render json: @ontology.errors, status: :unprocessable_entity }
    end
  end
end
