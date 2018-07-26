class CreateUserRelationships < ActiveRecord::Migration[5.1]
  def change
    create_table :user_relationships do |t|
      t.references :follower, foreign_key: { to_table: :users }, index: true, null: false
      t.references :followed, foreign_key: { to_table: :users }, index: true, null: false

      t.timestamps
    end

    # ある人が同じ人に対して複数回フォローすることを禁ずるための設定
    add_index :user_relationships, [:follower_id, :followed_id], unique: true
  end
end
