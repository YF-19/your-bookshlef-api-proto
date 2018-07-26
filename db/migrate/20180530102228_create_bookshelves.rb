class CreateBookshelves < ActiveRecord::Migration[5.1]
  def change
    create_table :bookshelves do |t|
      # 現時点では1人のユーザーが持てる本棚は1つとする（今後、本棚を複数持つようなユースケースがあるかもしれない）
      t.references :user, foreign_key: true, index: { unique: true }, null: false

      t.timestamps
    end
  end
end
