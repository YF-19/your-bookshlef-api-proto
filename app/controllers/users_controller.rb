class UsersController < ApplicationController
  before_action(:check_unauthenticated, only: [:create])
  before_action(:authenticate, only: [:update, :destroy, :authenticated_user])

  def create
    # payload = JSON.parse(request.body.string)
    # payload["password_confirmation"] = payload["password"]
    # user = User.new(payload)

    # ユーザー作成時のnameはusernameと同じにする
    params[:user][:name] = params[:user][:username]
    params[:user][:password_confirmation] = params[:user][:password]
    user = User.new(user_params())
    user.bookshelf = Bookshelf.new()

    if user.save()
      render json: {
        # セキュリティに関するカラムを送りたくないのでリロードする
        currentUser: User.find_by(id: user.id).camelized_attributes_with_additional_info(),
        token: generate_jwt(user)
      }, status: :created
    else
      render json: { messages: user.errors().full_messages() }, status: :bad_request
    end
  end

  def update
    # password_digestカラムがないとUPDATEできないため、unscoped()を使用する
    user = User.unscoped().find_by(id: params[:id])
    
    if user != current_user()
      render json: { messages: ['bad request'] }, status: :bad_request
    elsif user.update(user_params())
      render json: { updatedUser: nondirty_current_user().camelized_attributes_with_additional_info() }, status: :ok
    else
      render json: { messages: current_user().errors.full_messages() }, status: :bad_request
    end
  end

  def destroy
    if User.find_by(id: params[:id]) != current_user()
      render json: { messages: ['bad request'] }, status: :bad_request
    elsif current_user().destroy()
      render json: {}, status: :no_content
    else
      render json: { messages: current_user().errors.full_messages() }, status: :bad_request
    end
  end

  def authenticated_user
    render json: { currentUser: current_user().camelized_attributes_with_additional_info() }
  end

  private
    def user_params
      params.require(:user).permit(:username, :name, :email, :password, :password_confirmation)
    end
end
