class OntologySerializer < ActiveModel::Serializer
  attributes :code, :name, :desc, :created_at, :user

  def user
    object.user.name
  end

  has_many :queries

  def queries
    object.queries.collect { |query| query.id }
  end
end
