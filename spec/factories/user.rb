include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :user, :class => User do
    sequence(:email) { |n| "test#{n}@test.com" }
    password "password"
    password_confirmation "password"
  end
end
