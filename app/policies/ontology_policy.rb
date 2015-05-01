class OntologyPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def index?
    true
  end

  def show?
    @record.public? or user_is_owner?
  end

  def create?
    authenticated_user?
  end

  def update?
    user_is_owner?
  end

  def destroy?
    user_is_owner?
  end
end
