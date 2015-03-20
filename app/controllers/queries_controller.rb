class QueriesController < ApplicationController
  before_action :set_query, only: [:show, :edit, :update, :destroy]
  before_action :get_ontology

  def get_ontology
    @ontology = Ontology.where(code: params[:ontology_code]).first
  end

  # GET /queries
  # GET /queries.json
  def index
    @queries = @ontology.queries
  end


  # GET /queries/1
  # GET /queries/1.json
  def show
  end

  # GET /queries/new
  def new
    @query = Query.new
  end

  # GET /queries/1/edit
  def edit
  end




  # POST /queries
  # POST /queries.json
  def create
    @query = Query.new(query_params)
    @query.ontology = @ontology

    # get ontology dir
    require 'jena_jruby'

    dir = File.dirname("#{Rails.root}/db/tdb/#{@ontology.code}/dataSet")
    dataset = Jena::TDB::TDBFactory.createDataset(dir)
    dataset.begin(Jena::Query::ReadWrite::READ)

    query = "SELECT * WHERE { ?a ?b ?c} LIMIT 10"
    begin
      query = Jena::Query::QueryFactory.create(query)
      qexec = Jena::Query::QueryExecutionFactory.create(query, dataset)
      res = qexec.execSelect()

      # StringIO - org.jruby.util.IOOutputStream
      @out = StringIO.new
      stream = @out.to_outputstream

      Jena::Query::ResultSetFormatter.outputAsJSON(stream,res)
    rescue Exception => e
      puts "------ ERROR ------- " + e.to_s
    end

    qexec.close()
    dataset.end()

    respond_to do |format|
      if @query.save
        #format.html { redirect_to ontology_query_path(@ontology, @query), notice: 'Query was successfully created.' }
        #format.json { render , status: :created, location: @query }
        format.html { render :text => @out.string}
      else
        format.html { render :new }
        format.json { render json: @query.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /queries/1
  # PATCH/PUT /queries/1.json
  def update
    respond_to do |format|
      if @query.update(query_params)
        format.html { redirect_to ontology_query_path(@ontology, @query), notice: 'Query was successfully updated.' }
        format.json { render :show, status: :ok, location: @query }
      else
        format.html { render :edit }
        format.json { render json: @query.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /queries/1
  # DELETE /queries/1.json
  def destroy
    @query.destroy
    respond_to do |format|
      format.html { redirect_to ontology_queries_url, notice: 'Query was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_query
      @query = Query.joins(:ontology).where(ontologies: {code: params[:ontology_code]}, queries: {id: params[:id]}).first!
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def query_params
      params.require(:query).permit(:name, :content)
    end
end
