class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery prepend: true
   
  before_filter :configure_permitted_parameters, if: :devise_controller?
  before_filter :set_globals

  protected

  # devise parameter sanitization
  # see https://github.com/plataformatec/devise#strong-parameters
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :roles])

  end

  def set_globals
    @is_query_builder_query = (params[:builderUI_rule_0_filter] != nil)
  end
end
