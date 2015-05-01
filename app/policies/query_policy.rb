class QueryPolicy < ApplicationPolicy
  # no route for new, edit and update
  # so there is no need to define those

  class Scope < Scope
    def resolve
      scope
    end
  end

  # those who can see the ontology can see it's queries
  def index?
    Pundit.policy!(@user, @record.ontology).show?
  end

  def show?
    index?
  end

  def run?
    show?
  end

  def create?
    index? and authenticated_user?
  end

  # only the query owner or the ontology owner can delete a query
  def destroy?
    user_is_owner? or (authenticated_user? and @record.ontology.user_id == @user.id)
  end
end
