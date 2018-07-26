# 本棚と本の関係を表すモデルクラス
class StoredBook < ApplicationRecord
  include ModelHelper

  belongs_to(:bookshelf)
  belongs_to(:book)

  validates(:bookshelf, presence: true)
  validates(:book, presence: true)
  # 1つの本棚に同じ本を複数格納することはできない
  validates(:bookshelf, uniqueness: { scope: :book })
  # 格納できる本はステータスが利用可能でなくてはならない
  validate(:validate_book_should_be_only_available)

  private
    def validate_book_should_be_only_available
      message = 'status of a book will store (or stored) in a bookshelf should be only available'
      self.errors[:book].push(message) unless self.book().available?()
    end
end
