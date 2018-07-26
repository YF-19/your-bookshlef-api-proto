class SessionsController < ApplicationController
  before_action(:check_unauthenticated, only: [:login])

  def login
    username_or_email = params[:username_or_email].downcase()
    user = User.where(username: username_or_email).or(User.where(email: username_or_email))
      .unscope(:select)
      .first()
    
    if user && user.authenticate(params[:password])
      render json: {
        # セキュアでないカラムを送りたくないのでリロードする（reloadメソッドは全カラム取ってきてしまうので使えない）
        currentUser: User.find_by(id: user.id).camelized_attributes_with_additional_info(),
        token: generate_jwt(user)
      }, status: :ok
    else
      render json: { messages: ['Incorrect username or password.'] }, status: :unauthorized
    end
  end
end
