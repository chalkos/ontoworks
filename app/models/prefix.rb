class Prefix < ActiveRecord::Base
  belongs_to :ontology

  def to_s
    "PREFIX #{self.name}: <#{self.uri}>"
  end
end
