class CreateBooks < ActiveRecord::Migration[5.1]
  def change
    create_table :books do |t|
      t.string :isbn, null: false, limit: 13
      t.string :title, null: false
      t.string :subtitle
      t.string :authors
      t.string :publisher
      t.string :published_date
      t.text :description
      t.integer :page_count
      t.string :thumbnail_url
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :books, :isbn, unique: true
  end
end
