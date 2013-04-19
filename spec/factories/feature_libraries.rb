# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  factory :feature_library, :class => FeatureLibrary do
    name "erika's feature"
    user_id 12345
  end

  factory :feature_library2, :class => FeatureLibrary do
    name "erika's feature2"
    user_id 12345
  end

  factory :feature_library3, :class => FeatureLibrary do
    name "erika's feature3"
    user_id 98765
  end

  factory :feature_library4, :class => FeatureLibrary do
    name "erika's feature4"
    user_id 98765
  end



end
