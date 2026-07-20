FactoryBot.define do
  factory :vote do
    answer { "available" }
    association :candidate_date

    factory :user_vote do
      association :voter, factory: :user
    end

    factory :guest_vote do
      association :voter, factory: :guest
    end

    trait :maybe do
      answer { "maybe" }
    end

    trait :unavailable do
      answer { "unavailable" }
    end
  end
end
