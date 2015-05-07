class Query < ActiveRecord::Base
  belongs_to :ontology
  belongs_to :user

  validates :name   , presence: true, length: { in: 3..255 }
  validates :content, presence: true, length: { in: 1..1048576 }
  validates :user   , presence: true

  validate :content_is_a_valid_sparql_query

  before_validation :set_default_description_if_blank, on: :create

  attr_accessor :sparql

  private
  def content_is_a_valid_sparql_query
    if content.present?
      begin
        Jena::Query::QueryFactory.create(content)
      rescue Exception => e
        errors.add(:content, e.to_s)
      end
    end
  end

  def set_default_description_if_blank
    self.desc = '(no description)' if self.desc.blank?
    return true
  end
end
