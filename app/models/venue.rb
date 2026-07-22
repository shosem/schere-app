class Venue < ApplicationRecord
  belongs_to :event
  validates :name, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :name, length: { maximum: 255 }
  validates :note, length: { maximum: 10_000 }
end
