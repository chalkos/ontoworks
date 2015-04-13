class QueriesController < ApplicationController
  include QueriesHelper

  before_action :set_query, only: [:show, :destroy]
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

  # POST /run
  def run
    # Get a query
    @query = Query.new
    @query.content = request.post? ? params[:query][:content] : default_query_content
    @out_format = request.post? ? params[:query][:output] : default_query_output

    # Method
    errors = execute

    if errors.empty?
      case @out_format
      when "TXT"
        send_data @query.sparql, :filename => "result.txt"
      when "CSV"
        send_data @query.sparql, :filename => "result.csv"
      when "JSON"
        render :json => @query.sparql
      when "XML"
        render :xml => @query.sparql
      else
        render :run, collection: @query
      end
    else
      redirect_to ontology_queries_run_url, notice: errors
    end
  end

  # POST /queries
  # POST /queries.json
  def create
    @query = Query.new(query_params)
    @query.ontology = @ontology

    respond_to do |format|
      if @query.save
        format.json {
          render json: {
            error: [],
            name: @query.name,
            url: ontology_query_path(@ontology, @query)
          }
        }
      else
        format.json { render json: { error: @query.errors.full_messages } }
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

        case @out_format
        when "XML"
          Jena::Query::ResultSetFormatter.outputAsXML(stream,res)
          @query.sparql = out.string
        when "TXT"
          @query.sparql = Jena::Query::ResultSetFormatter.asText(res)
        when "CSV"
          Jena::Query::ResultSetFormatter.outputAsCSV(stream,res)
          @query.sparql = out.string
        else
          Jena::Query::ResultSetFormatter.outputAsJSON(stream,res)
          @query.sparql = JSON.parse out.string
        end

        qexec.close()
        dataset.end()

        errors = ""
      rescue Exception => e
        errors = e.to_s
      end
    end
end
