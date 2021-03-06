class QueriesController < ApplicationController
  include QueriesHelper

  before_action :set_query, only: [:show, :destroy]
  before_action :get_ontology
  after_action :verify_authorized

  #protect_from_forgery except: :run
  protect_from_forgery with: :null_session, :if => Proc.new { |c|  without_csrf.include? c.request.format }

  # GET /queries
  # GET /queries.json
  def index
    @queries = @ontology.queries
    @my_queries = @queries.where(user_id: current_user.id) if user_signed_in?

    if user_signed_in?
      @more_queries = @queries.where.not(user_id: current_user.id)
    else
      @more_queries = @queries
    end

    authorize @ontology, :show?

    respond_to do |format|
      format.html
      format.xml
      format.json  { render json: @queries }
    end
  end

  # GET /queries/1
  # GET /queries/1.json
  def show
    authorize @ontology, :show?

    respond_to do |format|
      format.html
      format.xml
      format.json  { render json: @query }
    end
  end

  def navigate
    authorize @ontology, :show?

    if params['uri'].nil?
      run
    else
      @uri = params[:uri]
      @query = Query.new

      dataset = Jena::TDB::TDBFactory.createDataset(@ontology.tdb_dir)
      dataset.begin(Jena::Query::ReadWrite::READ)

      begin
        res,qexec = exec_query(dataset,query_navigate(@uri),default_query_timeout)
        @query.content = query_navigate(@uri)

        out = StringIO.new
        Jena::Query::ResultSetFormatter.outputAsJSON(out.to_outputstream,res)
        @query.sparql = JSON.parse out.string

        qexec.close()
        errors = ""
      rescue Exception => e
        errors = e.to_s
      end

      dataset.end()

      respond_to do |format|
        if errors.empty?
          format.html { render :run, collection: @query }
        else
          @query.errors.add(:content, errors)
          format.html { render :run, collection: @query }
        end
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

    authorize @ontology, :show?

    # Method
    errors = execute

    if errors.empty? and !@query.sparql
      errors = "Query timed out - " + (@timeout * 0.001).to_i.to_s + " second(s)"
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
      @query.errors.add(:content, errors)
      case @out_format
      when "JSON"
        render :json => { :errors => @query.errors.full_messages }
      else
        render :run, collection: @query
      end
    end
  end

  # POST /queries
  # POST /queries.json
  def create
    @query = Query.new(query_params)

    authorize @ontology, :show?
    authorize @query

    @query.ontology = @ontology
    @query.user_id = current_user.id

    respond_to do |format|
      if @query.save
        log = Log.new(ontology_id: @ontology.id, user_id: current_user.id, query_name: @query.name)
        log.savequery!
        log.save
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

  # DELETE /queries/1
  # DELETE /queries/1.json
  def destroy
    authorize @ontology, :show?
    authorize_present @query

    log = Log.new(ontology_id: @ontology.id, user_id: current_user.id, query_name: @query.name)
    log.deletequery!
    log.save

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
      @ontology = Ontology.eager_load(:prefixes).where(code: params[:ontology_code]).first
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

        if qexec.getQuery().getQueryType() ==  Jena::Query::Query::QueryTypeConstruct #construct only makes sense as RDF/XML and res is a Model
          @out_format = "XML";
          res.write(stream, "RDF/XML-ABBREV")
          @query.sparql = out.string
        else
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
        end
        errors = ""
      rescue Exception => e
        errors = e.to_s
      ensure
        qexec.close() if qexec
        dataset.end()
        errors
      end
    end

    def exec_query(dataset,query,timeout)
      qfact = Jena::Query::QueryFactory.create(query)
      qexec = Jena::Query::QueryExecutionFactory.create(qfact, dataset)
      qexec.setTimeout(timeout)

      case qfact.getQueryType()
      when Jena::Query::Query::QueryTypeSelect
        res = qexec.execSelect()
      when Jena::Query::Query::QueryTypeAsk
        ask = qexec.execAsk() #ask is a boolean, so we need to create a ResultSet to show the results
        string = '{"head":{"vars":["Response"]},"results":{"bindings":[{"Response":{"type":"typed-literal","value":"' + ask.to_s + '"}}]}}'
        bytes = string.to_java_bytes
        inputstream = java.io.ByteArrayInputStream.new(bytes)
        res = Jena::Query::ResultSetFactory.fromJSON(inputstream)
      when Jena::Query::Query::QueryTypeDescribe
        desc = qexec.execDescribe()
        qexec.close()
        # desc is a model so we select everything in it, using a select query, and get a ResultSet
        qexec = Jena::Query::QueryExecutionFactory.create("Select * where {?s ?p ?o} ORDER BY ?s", desc)
        res = qexec.execSelect()
      when Jena::Query::Query::QueryTypeConstruct
        res= qexec.execConstruct()
      end
      return res,qexec
    end
end
