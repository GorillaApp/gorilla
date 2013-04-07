require 'faker'

FactoryGirl.define do
  factory :user, :class => User do
    email { Faker::Internet.email }
    password "password"
    password_confirmation "password"
  end
end
