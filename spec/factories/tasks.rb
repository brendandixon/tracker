FactoryGirl.define do
  factory :task do
    title 'Basic Task'
    points Task::POINTS.first
    project
  end
end
