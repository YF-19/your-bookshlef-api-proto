class UserRelationshipsController < ApplicationController
  before_action(:authenticate, only: [:create, :destroy])

  # 実装途中
  def create
    user = User.find_by(id: params[:followed_id])
    current_user().follow(user)
    # redirect_to user
  end

  # 実装途中
  def destroy
    user = UserRelationship.find(params[:id]).followed()
    current_user.unfollow(user)
    # redirect_to user
  end
end
