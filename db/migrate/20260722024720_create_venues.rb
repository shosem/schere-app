class CreateVenues < ActiveRecord::Migration[8.1]
  def change
    create_table :venues do |t|
      t.references :event, null: false, foreign_key: true
      t.string :name, null: false
      t.text :page_url
      t.integer :price
      t.text :note
      t.boolean :reserved, default: false, null: false
      t.timestamps
    end
  end
end
