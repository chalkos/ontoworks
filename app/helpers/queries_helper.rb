module QueriesHelper
  def format_cell(cell)
    # value - the lexical value of the object
    # (required, full URIs should be used, not qnames)
    # text = cell['value'].to_s || '_error_'

    # type - one of 'uri', 'literal' or 'bnode'
    # (required and must be lowercase)
    text = "[#{cell['type']}] " if cell['type']

    # lang - the language of a literal value
    # (optional but if supplied it must not be empty)
    text << "@#{cell['lang']}" if cell['lang']

    # datatype - the datatype URI of the
    # literal value (optional)
    text << "^^#{cell['datatype']} " if cell['datatype']

    text
  end

  def result_cell(cell)
    text = cell['value'].to_s || '_error_'
  end

  def namespace(cell)
    text = result_cell(cell).rpartition('#').first
  end

  def oclude(cell)
    text = namespace(cell).rpartition('/').last
  end

  def last(cell)
    text = "#" + result_cell(cell).rpartition('#').last
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
