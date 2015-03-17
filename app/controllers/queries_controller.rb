class QueriesController < ApplicationController
  before_action :set_query, only: [:show, :edit, :update, :destroy]

  # GET /queries
  # GET /queries.json
  def index
    @queries = Query.all
  end


  # GET /queries
  # GET /queries.json
  def index_dont_use_this_one
    return nil; #just to be safe

    @queries = Query.all


    dir = File.dirname("#{Rails.root}/db/tdb/teste/dummy")


    # e aqui começa a mistura de java com ruby
    require 'jena_jruby'

    t1 = java.lang.System.currentTimeMillis();

    dataset = Jena::TDB::TDBFactory.createDataset(dir)
    dataset.begin(Jena::Query::ReadWrite::READ)
    model = dataset.getDefaultModel()
    dataset.end()

    t2 = java.lang.System.currentTimeMillis()
    @tempo = {carregar: t2-t1}
    #System.out.println("carregar o modelo: " + (t2 - t1) + " milliseconds.")

    queryString = "select * where {?a ?b ?c} LIMIT 10"
    query = Jena::Query::QueryFactory.create(queryString)

    begin
      qexec = Jena::Query::QueryExecutionFactory.create(query, model)
      results = qexec.execSelect()

      t3 = java.lang.System.currentTimeMillis()
      #System.out.println("fazer a query e obter o resultado: " + (t3 - t2) + " milliseconds.")
      @tempo[:query] = t3-t2

      Jena::Query::ResultSetFormatter.out(java.lang.System.out, results, query)
      puts "should have been done by now"
    rescue Exception => e
      puts "\n\n-------------------------\nGOT AN EXCEPTION!\n-------------------------\n\n"
    end


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

    respond_to do |format|
      if @query.save
        format.html { redirect_to @query, notice: 'Query was successfully created.' }
        format.json { render :show, status: :created, location: @query }
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
        format.html { redirect_to @query, notice: 'Query was successfully updated.' }
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
      format.html { redirect_to queries_url, notice: 'Query was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_query
      @query = Query.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def query_params
      params.require(:query).permit(:name, :content)
    end
end
