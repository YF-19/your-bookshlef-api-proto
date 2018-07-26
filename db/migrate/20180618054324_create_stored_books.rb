class CreateStoredBooks < ActiveRecord::Migration[5.1]
  def change
    create_table :stored_books do |t|
      t.references :bookshelf, foreign_key: true, index: true, null: false
      t.references :book, foreign_key: true, index: true, null: false

      t.timestamps
    end

    # 1つの本棚に同じ本を追加できないようにするための設定
    add_index :stored_books, [:bookshelf_id, :book_id], unique: true
  end
end
