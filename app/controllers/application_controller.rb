class ApplicationController < ActionController::Base
  include Pundit

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Show a flash message when not authorized
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private
  def raise_404
    raise ActionController::RoutingError.new('Not Found')
  end

  def authorize_present(resource)
    if resource.present?
      authorize resource
    else
      raise_404
    end
  end

  def user_not_authorized(exception)
    policy_name = exception.policy.class.to_s.underscore

    if request.format.html?
      flash[:alert] = t "#{policy_name}.#{exception.query}", scope: "pundit", default: :default
      redirect_to(request.referrer || root_path)
    else
      render :status => :forbidden, :text => "Forbidden Request"
    end
  end
end
