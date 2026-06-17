FactoryBot.define do
  factory :user do
    name { "テストユーザくん" }
    sequence(:email) { |n| "test#{n}@example.com" }
    password { "pass" }
  end
end
