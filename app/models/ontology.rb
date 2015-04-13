class Ontology < ActiveRecord::Base
  validates_uniqueness_of :code
  has_many :queries

  validates :name, presence: true, length: { in: 3..255 }
  validates :file, presence: true
  validate :valid_content_type

  attr_accessor :file

  def to_param
    code
  end

  def tdb_dir
    "#{Rails.root}/db/tdb/#{code}"
  end

  def valid_content_type
    unless file.blank?
      allowed = ["application/gzip","application/zip","text/xml","application/rdf+xml","application/octet-stream"]

      errors.add(:file,"Invalid file type. Valid formats are xml, zip and tar.gz") unless allowed.include? file.content_type
    end
  end
end
