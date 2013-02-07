class ApplicationController < ActionController::Base
  
  protect_from_forgery

  before_filter :authenticate_user!

  # authorize_resource
  # skip_authorize_resource only: :sign_out

  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    redirect_to root_path
  end

end
