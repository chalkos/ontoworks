class Log < ActiveRecord::Base
  enum msg_type: [:ontologycreate, :savequery, :codechange]
  belongs_to :ontology
  belongs_to :user
  belongs_to :query

def to_s
  case self.msg_type
  when "ontologycreate"
    "Ontology  was created"
  when "savequery"
    ontology = Ontology.find(self.ontology_id)
    query = ontology.queries.find(self.query_id)
    user = User.find(self.user_id)
    "Query '" + query.name + "' was saved by user '" + user.name + "'"
  when "codechange"
    "Code changed from " + self.from_code + " to " + self.to_code
  end
end

end
