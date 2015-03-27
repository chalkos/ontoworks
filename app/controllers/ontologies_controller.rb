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
    @ontology = Ontology.new(ontology_params)
    @ontology.code = @ontology.hash

    @file = params[:ontology]['file']
    ## UNZIP START, IF NECESSARY
    require 'zip'
    if File.extname(@file.original_filename) == ".zip"
      # open zip file
      Zip::File.open(@file.path) do |zip_file|
        zip_file.each do |entry|
          @file = File.join('public/', entry.name)
          FileUtils.mkdir_p(File.dirname(@file))
          zip_file.extract(entry, @file)
        end
      end
    else
      @file = params[:ontology]['file'].path
    end

    ## JENA START
    require 'jena_jruby'

    dir = File.dirname("#{Rails.root}/db/tdb/geral/dataSet")
    FileUtils.mkdir_p(dir) unless File.directory?(dir)

    dataset = Jena::TDB::TDBFactory.createDataset(dir) #create or connect

    dataset.begin(Jena::Query::ReadWrite::WRITE)
    model = dataset.getNamedModel(@ontology.code)

    #open the ontology
    input = Jena::Util::FileManager.get().open(@file)

    #read the RDF/XML file
    begin
      model.read(input, nil)
    rescue Exception => e
      puts "----- ERROR -----" + e
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
      if @ontology.update(ontology_params)
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
      params.require(:ontology).permit(:name, :code, :unlisted, :extendable, :expires)
    end
end
