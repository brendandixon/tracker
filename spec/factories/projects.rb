FactoryGirl.define do
  factory :project do
    name 'Basic Project'
    start_date { 6.months.ago }
  end
end
