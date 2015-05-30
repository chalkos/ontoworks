class Log < ActiveRecord::Base
  enum msg_type: [:ontologycreate, :savequery, :deletequery, :codechange, :updatedesc, :updatepublic, :updateshared]
  belongs_to :ontology
  belongs_to :user

  def to_s
    case self.msg_type
    when "ontologycreate"
      "Ontology  was created"
    when "savequery"
      user = User.find(self.user_id)
      "Query <b>" + self.query_name + "</b> was saved by user <b>" + user.name + "</b>"
    when "deletequery"
      user = User.find(self.user_id)
      "Query <b>" + self.query_name + "</b> was deleted by user <b>" + user.name + "</b>"
    when "codechange"
      "Code changed from " + self.from_code + " to " + self.to_code
    when "updatedesc"
      ont = Ontology.find(self.ontology_id)
      user = User.find(ont.user_id)
      "Owner <b>" + user.name + "</b> updated this ontology's description"
    when "updatepublic"
      self.helper ? "Ontology was changed to public" : "Ontology was changed to private"
    when "updateshared"
      self.helper ? "Ontology was changed to shared" : "Ontology was changed to not shared"
    end
  end

  def self.visitor_types
    return[Log.msg_types[:ontologycreate], Log.msg_types[:savequery], Log.msg_types[:deletequery], Log.msg_types[:updatedesc]]
  end

end
