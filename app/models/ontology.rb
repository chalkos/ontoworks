class Ontology < ActiveRecord::Base
  validates_uniqueness_of :code
  has_many :queries


  def to_param
    code
  end
end
