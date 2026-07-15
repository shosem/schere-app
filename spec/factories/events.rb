FactoryBot.define do
  factory :event do
    transient do
      candidate_dates_count { 1 }
    end
    sequence(:title) { |n| "テスト#{n}" }
    location { "東京" }
    description { "説明" }
    after(:build) do |event, evaluator|
      event.candidate_dates = build_list(:candidate_date, evaluator.candidate_dates_count, event: event)
    end
    association :group
    association :user
  end
end
