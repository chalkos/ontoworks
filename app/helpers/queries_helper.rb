module QueriesHelper
  def format_result_cell(cell)
    # value - the lexical value of the object
    # (required, full URIs should be used, not qnames)
    text = cell['value'].to_s || '_error_'

    # type - one of 'uri', 'literal' or 'bnode'
    # (required and must be lowercase)
    text.prepend "[#{cell['type']}] " if cell['type']

    # lang - the language of a literal value
    # (optional but if supplied it must not be empty)
    text << "@#{cell['lang']}" if cell['lang']

    # datatype - the datatype URI of the
    # literal value (optional)
    text << "^^#{cell['datatype']}" if cell['datatype']

    text
  end

  def default_query_content
    "select distinct ?Concept where {\n  [] a ?Concept\n} LIMIT 100"
  end
end
