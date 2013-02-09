# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :reference do
    reference_type_id 1
    value "MyString"
  end
end
