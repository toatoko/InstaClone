class CreateLikes < ActiveRecord::Migration[8.0]
  def change
    create_table :likes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :post, null: false, foreign_key: true
      t.timestamps
    end

    add_index :likes, [ :user_id, :post_id ], unique: true
    add_index :likes, :post_id unless index_exists?(:likes, :post_id)
  end
end
