class OntologyPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def index?
    true
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

  private
  def user_is_owner?
    return @record.user_id == @user.id if authenticated_user?
    false
  end
end
