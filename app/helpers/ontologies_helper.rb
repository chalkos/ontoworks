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
    "\##{query.name}\n\##{query.desc}\n\##{query.user.name}\n#{query.content}"
  end

  def name_file(query)
    "queries/query#{query.id}.txt"
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
end
