# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :referent_reference do
    referent_id 1
    referent_type "MyString"
    reference_id 1
  end
end
