class QueriesController < ApplicationController
  before_action :set_query, only: [:show, :destroy]
  before_action :get_ontology

  attr_accessor :sparql

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
    execute
  end

  # POST /run
  def run
    # Get a query
    @query = Query.new
    @query.content = params[:query][:content]

    # Method
    errors = execute

    respond_to do |format|
      if errors.empty?
        format.html { render :run, collection: @query }
      else
        format.html { redirect_to ontology_queries_url, notice: errors }
      end
    end
  end

  # POST /queries
  # POST /queries.json
  def create
    @query = Query.new
    @query.ontology = @ontology
    @query.name = params[:content][0]
    @query.desc = params[:content][1]
    @query.content = params[:content][2]

    # validate required fields
    errors = ""
    if(@query.name == "")
      errors += "No query title! "
    end
    if(@query.content == "")
      errors += "No query content! "
    else
      errors += validate
    end

    respond_to do |format|
      if @query.save
        format.json {
          render json: {
            error: [],
            name: @query.name,
            url: ontology_query_path(@ontology, @query)
          }
        }
      end
    end
  end

  # PATCH/PUT /queries/1
  # PATCH/PUT /queries/1.json
  # def update
  #   respond_to do |format|
  #     if @query.update(query_params)
  #       format.html { redirect_to ontology_query_path(@ontology, @query), notice: 'Query was successfully updated.' }
  #       format.json { render :show, status: :ok, location: @query }
  #     else
  #       format.html { render :edit }
  #       format.json { render json: @query.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

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
      params.require(:query).permit(:name, :desc, :content)
    end

    # Auxiliar Method
    def execute
      require 'jena_jruby'

      dir = File.dirname("#{Rails.root}/db/tdb/#{@ontology.code}/dataSet")
      dataset = Jena::TDB::TDBFactory.createDataset(dir)
      dataset.begin(Jena::Query::ReadWrite::READ)

      begin
        query = Jena::Query::QueryFactory.create(@query.content)
        qexec = Jena::Query::QueryExecutionFactory.create(@query.content, dataset)
        res = qexec.execSelect()

        # StringIO - org.jruby.util.IOOutputStream
        out = StringIO.new
        stream = out.to_outputstream

        Jena::Query::ResultSetFormatter.outputAsJSON(stream,res)
        qexec.close()
        dataset.end()

        @query.sparql = JSON.parse out.string
        errors = ""
      rescue Exception => e
        errors = e.to_s
      end
    end

    def validate
      begin
        query = Jena::Query::QueryFactory.create(@query.content)
        errors = ""
      rescue Exception => e
        errors = e.to_s
      end
    end
end
