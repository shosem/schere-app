class CreateCandidateDates < ActiveRecord::Migration[8.1]
  def change
    create_table :candidate_dates do |t|
      t.references :event, null: false, foreign_key: true
      t.date :date, null: false
      t.time :start_time
      t.time :end_time
      t.timestamps
    end
  end
end
