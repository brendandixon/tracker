FactoryGirl.define do
  factory :task do
    title 'Basic Task'
    points Task::POINTS_MINIMUM
    project
  end
end
