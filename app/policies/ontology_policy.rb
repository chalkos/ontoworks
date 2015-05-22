class OntologyPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def index?
    true
  end

  def change_code?
    user_is_owner?
  end

  def show?
    @record.public? or @record.shared? or user_is_owner?
  end

  def download?
    show?
  end

  def create?
    authenticated_user?
  end

  def update?
    user_is_owner?
  end

  def update_query?
    user_is_owner?
  end

  def destroy?
    user_is_owner?
  end
end
