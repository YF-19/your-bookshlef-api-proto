# 本棚モデルのクラス
class Bookshelf < ApplicationRecord
  include ModelHelper
  
  belongs_to(:user)
  has_many(:stored_books, dependent: :destroy)
  has_many(:books, through: :stored_books)

  # 現時点ではユーザーはただ1つの本棚を持つこととする
  validates(:user_id, presence: true, uniqueness: true)
end
