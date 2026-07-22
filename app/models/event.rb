class Event < ApplicationRecord
  belongs_to :user
  belongs_to :group
  has_many :candidate_dates, dependent: :destroy
  has_many :venues, dependent: :destroy
  belongs_to :confirmed_candidate_date,
             class_name: "CandidateDate",
             optional: true
  accepts_nested_attributes_for :candidate_dates, allow_destroy: true
  enum :status, { adjusting: 0, confirmed: 1, cancelled: 2 }, default: :adjusting

  validates :title, presence: true, length: { maximum: 25 }
  validates :description, length: { maximum: 10_000 }
  validates :candidate_dates, presence: true
end
