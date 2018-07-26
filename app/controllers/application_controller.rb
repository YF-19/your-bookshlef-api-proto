class ApplicationController < ActionController::API
  # protect_from_forgery with: :null_sesssion

  include ActionController::Cookies
  include SessionsHelper
end
