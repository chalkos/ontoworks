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
end
