class CandidateDate < ApplicationRecord
  belongs_to :event
  has_many :votes, dependent: :destroy
  validates :date, presence: true
end
