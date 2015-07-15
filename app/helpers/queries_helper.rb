module QueriesHelper
  def format_cell(cell)
    # type - one of 'uri', 'literal' or 'bnode'
    # (required and must be lowercase)
    text = "[#{cell['type']}]  " if cell['type']

    text
  end

  def result_cell(cell)
    text = cell['value'].to_s || '_error_'
  end

  def namespace(input)
    text = input.rpartition('#').first
  end

  def oclude(input)
    text = namespace(input)
    res = nil
    #search the prefixes of this ontology
    @ontology.prefixes.each do |x|
      res = x.name if x.uri.include? text
    end
    if res == nil or res == ""
      res = text.rpartition('/').last
    end
    res + ":"
  end

  def last(input)
    text = input.rpartition('#').last
  end

  def lang(cell)
      text = "@#{cell['xml:lang']}"  if cell['xml:lang']
  end

  def user_owns_query(query)
    return query.user_id == current_user.id if user_signed_in?
    false
  end

  def default_query_content
    "SELECT DISTINCT ?class WHERE {\n [] a ?class\n} ORDER BY ?class"
  end

  def properties_query_content
    "SELECT DISTINCT ?property WHERE {\n [] ?property []\n} ORDER BY ?property"
  end

  def default_query_output
    "HTML"
  end

  def default_query_timeout
    30000
  end

  def query_navigate(uri)
    "SELECT * WHERE {\n  {?subject ?predicate <#{uri}>} UNION\n  {?subject <#{uri}> ?object} UNION\n  {<#{uri}> ?predicate ?object}\n}"
  end

  def without_csrf
    return ["application/json","text/xml"]
  end
end
