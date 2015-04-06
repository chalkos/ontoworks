class Query < ActiveRecord::Base
  belongs_to :ontology

  attr_accessor :sparql
end
