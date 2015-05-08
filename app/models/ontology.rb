class Ontology < ActiveRecord::Base
  include OntologiesHelper

  has_many :queries
  belongs_to :user

  validates :public, :shared, inclusion: [true, false]
  validates_presence_of :user
  validates_presence_of :file, on: :create
  validates :code, uniqueness: true
  validates :name, presence: true, length: { in: 3..255 }
  validate :valid_content_type, :number_of_files

  before_validation :set_default_description_if_blank, on: [:create, :update]
  before_validation :set_shared_to_false, on: :create

  attr_accessor :file

  def to_param
    code
  end

  def tdb_dir
    "#{Rails.root}/db/tdb/#{code}"
  end

  def valid_content_type
    if file.present?
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

  def set_shared_to_false
    self.shared = false
    return true
  end

  def set_default_description_if_blank
    self.desc = '(no description)' if self.desc.blank?
    return true
  end

  def add_default_queries! query_model
    queries = [
      query_model.new(
        name: "Classes",
        content: "SELECT DISTINCT ?class WHERE {\n [] a ?class\n} ORDER BY ?class",
        desc: "Lists all classes for this ontology."
      ),
    ]

    queries.each do |q|
      q.ontology_id = self.id
      q.user_id = self.user_id
      q.save!
    end
  end
end
