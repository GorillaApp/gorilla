require 'faker'

FactoryGirl.define do
  factory :feature, :class => Features do
    user_id 1234
    forward_color "#F54321"
    reverse_color "#F12345"
    add_attribute :sequence, "atctgctccctag"
    name "DICKS"
  end
end
