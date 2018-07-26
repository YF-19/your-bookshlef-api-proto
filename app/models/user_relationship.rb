class UserRelationship < ApplicationRecord
  include ModelHelper
  
  belongs_to(:follower, class_name: 'User')
  belongs_to(:followed, class_name: 'User')

  validates(:follower, presence: true)
  validates(:followed, presence: true)
  # あるユーザーが同じユーザーを複数回フォローすることはできない
  validates(:follower, uniqueness: { scope: :followed })
  # ユーザー自身をフォローすることはできない
  validate(:validate_forbidden_to_follow_myself)

  private
    def validate_forbidden_to_follow_myself
      message = "You can't follow yourself"
      self.errors[:base] << message if self.follower&.is?(self.followed)
    end
end
