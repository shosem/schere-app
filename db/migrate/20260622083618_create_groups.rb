class CreateGroups < ActiveRecord::Migration[8.1]
  def change
    create_table :groups do |t|
      t.references :user, foreign_key: true
      t.string :name, null: false
      t.string :join_token
      t.index :join_token, unique: true
      t.timestamps
    end
  end
end
