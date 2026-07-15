FactoryBot.define do
  factory :candidate_date do
    sequence(:date) { |n| Date.tomorrow + n.days }
    association :event
  end
end
