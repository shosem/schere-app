class Vote < ApplicationRecord
  belongs_to :candidate_date
  belongs_to :voter, polymorphic: true
  validates :answer, presence: true
  validates :voter_id, uniqueness: { scope: [ :candidate_date_id, :voter_type ] }
  enum :answer, { unavailable: 0, maybe: 1, available: 2 }
end
