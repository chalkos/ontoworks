class QuerySerializer < ActiveModel::Serializer
  attributes :id, :name, :desc, :content, :created_at, :ontology, :user

  def ontology
    object.ontology.code
  end

  def user
    object.user.name
  end
end
