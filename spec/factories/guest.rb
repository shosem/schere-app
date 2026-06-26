FactoryBot.define do
  factory :guest do
    sequence(:name) { |n| "テストゲスト#{n}" }
    association :group
  end
end
