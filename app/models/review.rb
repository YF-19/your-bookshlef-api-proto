# 本のレビューのモデルクラス
class Review < ApplicationRecord
  include ModelHelper
  
  belongs_to(:user)
  belongs_to(:book)

  validates(:user, presence: true)
  validates(:book, presence: true)
  # ユーザーは1つの本に複数のレビューを書くことができない（投稿したレビューを更新することは可能）
  validates(:user, uniqueness: { scope: :book })
  validate(:validate_reviewable)
  validates(:rating, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 5 })
  validates(:body, presence: true, length: { maximum: 4096 })
  
  private
    def validate_reviewable
      message = "You can't review for a book that is not stored in your bookshelf"
      self.errors[:base] << message unless self.user()&.has?(self.book()) # bookがnilの場合でも、メッセージが追加されてしまうが一旦これでよしとする
    end    
end
