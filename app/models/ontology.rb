class Ontology < ActiveRecord::Base
  include OntologiesHelper

  has_many :queries
  belongs_to :user


  validates :public, :public_readonly, :shared, :shared_readonly, inclusion: [true, false]
  validates_presence_of :user
  validates_presence_of :file, on: :create
  validates :code, uniqueness: true
  validates :name, presence: true, length: { in: 3..255 }
  validate :valid_content_type, :number_of_files

  attr_accessor :file

  def to_param
    code
  end

  def tdb_dir
    "#{Rails.root}/db/tdb/#{code}"
  end

  def valid_content_type
    unless file.blank?
      allowed = ["application/gzip","application/zip","text/xml","application/rdf+xml","application/octet-stream","application/x-gzip"]

      errors.add(:file,"Invalid file type. Valid formats are xml, zip and tar.gz") unless allowed.include? file.content_type
    end
  end

  def number_of_files
    unless file.blank?
      case validate_file(file)
      when :gz
        tars = Gem::Package::TarReader.new(Zlib::GzipReader.open(file.path)).each

        errors.add(:file, "The uploaded package must contain a single file.") unless tars.count == 1
      when :zip
        zips = Zip::File.open(file.path).count

        errors.add(:file, "The uploaded package must contain a single file.") unless zips == 1
      end
    end
  end
end
