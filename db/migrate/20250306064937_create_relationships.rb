class CreateRelationships < ActiveRecord::Migration[8.0]
  def change
    create_table :relationships do |t|
      t.references :follower, null: false, foreign_key: { to_table: :users }, index: true
      t.references :followed_user, null: false, foreign_key: { to_table: :users }, index: true

      t.timestamps
    end

    add_index :relationships, [:follower_id, :followed_user_id], unique: true, name: 'index_relationships_on_follower_and_followed'
  end
end
