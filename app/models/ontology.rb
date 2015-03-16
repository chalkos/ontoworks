class Ontology < ActiveRecord::Base
  :has_many :queries


  # override
  def to_param
    hash
  end
end
