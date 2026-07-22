FactoryBot.define do
  factory :venue do
    name { "居酒屋" }
    reserved { false }
    association :event

    trait :reserved do
      reserved { true }
    end
  end
end
