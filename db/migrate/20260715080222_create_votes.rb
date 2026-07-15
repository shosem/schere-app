class CreateVotes < ActiveRecord::Migration[8.1]
  def change
    create_table :votes do |t|
      t.integer :answer
      t.bigint :voter_id
      t.string :voter_type

      t.timestamps
    end
  end
end
