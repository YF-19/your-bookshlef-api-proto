class CreateReviews < ActiveRecord::Migration[5.1]
  def change
    create_table :reviews do |t|
      t.references :user, foreign_key: true, index: true, null: false
      t.references :book, foreign_key: true, index: true, null: false
      t.integer :rating, default: 0
      t.text :body, null: false, limit: 4096

      t.timestamps
    end

    # 1つのブックに1人のユーザーがレビューできるのは1回までにするための設定
    add_index :reviews, [:user_id, :book_id], unique: true
  end
end
