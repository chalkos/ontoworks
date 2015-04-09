class Query < ActiveRecord::Base
  belongs_to :ontology

  validates :name   , presence: true, length: { in: 3..255 }
  validates :content, presence: true, length: { in: 1..1048576 }
  validate :content_is_a_valid_sparql_query

  attr_accessor :sparql

  def content_is_a_valid_sparql_query
    if content.present?
      begin
        Jena::Query::QueryFactory.create(content)
      rescue Exception => e
        errors.add(:content, e.to_s)
      end
    end
  end
end
