FactoryBot.define do
  factory :candidate_date do
    sequence(:date) { |n| Date.new(2026, 07, 15) + n.days }
    association :event
  end
end
