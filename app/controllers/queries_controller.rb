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

  def navigate

    if params['uri'].nil?
      run
    else
      uri = params[:uri]

      dataset = Jena::TDB::TDBFactory.createDataset(@ontology.tdb_dir)
      dataset.begin(Jena::Query::ReadWrite::READ)

      begin
        n_read,res = exec_query(dataset, query_subject, default_query_timeout)
        if(n_read == 0)
          n_read,res = exec_query(dataset, query_predicate, default_query_timeout)
          if(n_read == 0)
            n_read,res = exec_query(dataset, query_object, default_query_timeout)
          end
        end

        out = StringIO.new
        stream = out.to_outputstream

        Jena::Query::ResultSetFormatter.outputAsJSON(stream,res)
        sparql = JSON.parse out.string

      rescue Exception => e
        error = e.to_s
      end
      dataset.end

      respond_to do |format|
        format.html { render :text => "#{sparql}" }
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

      dataset = Jena::TDB::TDBFactory.createDataset(@ontology.tdb_dir)
      dataset.begin(Jena::Query::ReadWrite::READ)

      begin
        n_read,res,q_exec = exec_query(dataset,@query.content,@timeout)

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

        #q_exec.close()
        dataset.end()

        errors = ""
      rescue Exception => e
        errors = e.to_s
      end
    end

    def exec_query(dataset,query,timeout)
      q_fact = Jena::Query::QueryFactory.create(query)
      q_exec = Jena::Query::QueryExecutionFactory.create(q_fact, dataset)
      q_exec.setTimeout(timeout)
      res = q_exec.execSelect()

      read = Jena::Query::ResultSetFormatter.consume(res)

      return read,res,q_exec
    end
end
