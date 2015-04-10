class Ontology < ActiveRecord::Base
  validates_uniqueness_of :code
  has_many :queries


  def to_param
    code
  end

  def tdb_dir
    "#{Rails.root}/db/tdb/#{code}"
  end
end
