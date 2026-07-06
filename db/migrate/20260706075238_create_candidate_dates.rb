class CreateCandidateDates < ActiveRecord::Migration[8.1]
  def change
    create_table :candidate_dates do |t|
      t.timestamps
    end
  end
end
