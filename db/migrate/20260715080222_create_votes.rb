class CreateVotes < ActiveRecord::Migration[8.1]
  def change
    create_table :votes do |t|
      t.references :candidate_date, null: false, foreign_key: true
      t.integer :answer, null: false
      t.bigint :voter_id, null: false
      t.string :voter_type, null: false
      t.index [ :candidate_date_id, :voter_type, :voter_id ], unique: true
      t.index [ :voter_type, :voter_id ]

      t.timestamps
    end
  end
end
