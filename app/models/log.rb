class Log < ActiveRecord::Base
  enum msg_type: [:ontologycreate, :savequery, :deletequery, :codechange]
  belongs_to :ontology
  belongs_to :user

def to_s
  case self.msg_type
  when "ontologycreate"
    "Ontology  was created"
  when "savequery"
    user = User.find(self.user_id)
    "Query '" + self.query_name + "' was saved by user '" + user.name + "'"
  when "deletequery"
    user = User.find(self.user_id)
    "Query '" + self.query_name + "' was deleted by user '" + user.name + "'"
  when "codechange"
    "Code changed from " + self.from_code + " to " + self.to_code
  end
end

end
