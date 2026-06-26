class CreateGuests < ActiveRecord::Migration[8.1]
  def change
    create_table :guests do |t|
      t.references :group, null: false, foreign_key: true
      t.string :name, null: false
      t.string :session_token, null: false
      t.index [ :name, :group_id], unique: true
      t.index :session_token, unique: true

      t.timestamps
    end
  end
end
