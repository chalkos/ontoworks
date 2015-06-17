module OntologiesHelper
  def validate_file(file)
    type = file.content_type
    if ["application/gzip","application/x-gzip"].include? type
      :gz
    elsif type == "application/zip"
      :zip
    elsif type.include? "xml"
      :xml
    else
      :other
    end
  end

  def user_owns_ontology(ontology)
    return ontology.user_id == current_user.id if user_signed_in?
    false
  end

  def description(query)
    "\#Name: #{query.name}\n\#Description: #{query.desc}\n\#Author: #{query.user.name}\n#{query.content}"
  end

  def name_query(query)
    "queries/#{query.id}_" + name_file(query.name,'.rq')
  end

  def download_defs(params)
    type = params[:download][:type]

    case type
    when "TURTLE"; ext = ".ttl"
    when "RDF/JSON"; ext = ".json"
    when "N-TRIPLES"; ext = ".nt"
    when "RDF/XML-ABBREV"; ext= ".rdf"
    else
      ext = ".rdf"
      type = "RDF/XML-ABBREV"
    end

    return type, ext
  end

  def name_file(name, ext)
    name.gsub(/[^\w\s_-]+/, '').gsub(/(^|\b\s)\s+($|\s?\b)/, '\\1\\2').gsub(/\s+/, '_') + ext
  end
end
