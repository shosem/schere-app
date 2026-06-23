FactoryBot.define do
  factory :group do
    sequence(:name) { |n| "テストグループ#{n}"}
    association :user
  end
end
