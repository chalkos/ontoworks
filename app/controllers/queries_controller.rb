class QueriesController < ApplicationController
  include QueriesHelper

  before_action :set_query, only: [:show, :destroy]
  before_action :get_ontology
  after_action :verify_authorized

  # GET /queries
  # GET /queries.json
  def index
    @queries = @ontology.queries
    @my_queries = @queries.where(user_id: current_user.id) if user_signed_in?
    @more_queries = @queries.where.not(user_id: current_user.id) if user_signed_in?
    authorize @queries
  end

  # GET /queries/1
  # GET /queries/1.json
  def show
    authorize_present @query
  end

  def navigate
    if params['uri'].nil?
      run
    else
      uri = params[:uri]
      @query = Query.new

      dataset = Jena::TDB::TDBFactory.createDataset(@ontology.tdb_dir)
      dataset.begin(Jena::Query::ReadWrite::READ)

      begin
        res,qexec = exec_query(dataset,query_subject(uri),default_query_timeout)
        @query.content = query_subject(uri)
        if(res.size == 0)
          res,qexec = exec_query(dataset,query_predicate(uri),default_query_timeout)
          @query.content = query_predicate(uri)
          if(res.size == 0)
            res,qexec = exec_query(dataset,query_object(uri),default_query_timeout)
            @query.content = query_object(uri)
          end
        end

        out = StringIO.new
        Jena::Query::ResultSetFormatter.outputAsJSON(out.to_outputstream,res)
        @query.sparql = JSON.parse out.string

        qexec.close()
        errors = ""
      rescue Exception => e
        errors = e.to_s
      end

      dataset.end()

      if errors.empty?
        respond_to do |format|
          format.html { render :run, collection: @query }
        end
      else
        redirect_to ontology_queries_run_url, notice: errors
      end
    end
  end

  # POST /run
  def run
    # Get a query
    @query = Query.new
    @query.content = request.post? ? params[:query][:content] : default_query_content
    @out_format = request.post? ? params[:query][:output] : default_query_output
    time = request.post? ? params[:query][:timeout].to_i : default_query_timeout
    @timeout = time.between?(1, 3600) ? time * 1000 : default_query_timeout

    authorize @query

    # Method
    errors = execute

    if errors.empty? and !@query.sparql
      errors = "Query timed out - " + time.to_s + " second(s)"
    end

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
      flash.now[:notice] = errors
      render :run, collection: @query
    end
  end

  # POST /queries
  # POST /queries.json
  def create
    @query = Query.new(query_params)
    @query.ontology = @ontology
    @query.user_id = current_user.id if user_signed_in?

    authorize @query

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
    authorize_present @query

    @query.destroy
    respond_to do |format|
      format.html { redirect_to ontology_queries_url, notice: 'Query was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_query
      # possível optimização usando eager_load em vez de joins e incluir também os autores das queries
      @query = Query.joins(:ontology).where(ontologies: {code: params[:ontology_code]}, queries: {id: params[:id]}).first!
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def query_params
      params.require(:query).permit(:name, :desc, :content)
    end

    # Get ontology from the URL
    def get_ontology
      @ontology = Ontology.where(code: params[:ontology_code]).first
    end

    # Auxiliar Method
    def execute
      require 'jena_jruby'

      dataset = Jena::TDB::TDBFactory.createDataset(@ontology.tdb_dir)
      dataset.begin(Jena::Query::ReadWrite::READ)

      begin
        res,qexec = exec_query(dataset,@query.content,@timeout)

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

    def exec_query(dataset,query,timeout)
      qfact = Jena::Query::QueryFactory.create(query)
      qexec = Jena::Query::QueryExecutionFactory.create(qfact, dataset)
      qexec.setTimeout(timeout)
      res = Jena::Query::ResultSetFactory.makeRewindable(qexec.execSelect())

      return res,qexec
    end
end
