namespace :tracker do
  
  namespace :project do

    desc 'Ensure all projects have start dates'
    task ensure_start_dates: :environment do
      Project.where(start_date: nil).update_all(start_date: DateTime.parse('2012-12-01'))
    end

  end

  namespace :seed do

    desc 'Purge all data'
    task purge: :environment do
      [Category, Feature, FeatureProject, Filter, Project, Reference, ReferenceType, ReferentReference, Role, Story, Task, Team, User].each do |model|
        model.delete_all
      end
    end

    desc 'Create standard roles'
    task default: :environment do
      [:admin, :developer, :scrum_master, :observer].each do |role|
        r = Role.new(name: role.to_s.camelize)
        r.save
      end
      u = User.new(email: 'brendandixon@me.com', password: 'idlmkvvm')
      u.roles << Role.where(name: 'Admin').first
      u.roles << Role.where(name: 'ScrumMaster').first
      u.save
    end

  end

  namespace :task do

    desc 'Ensure task dates'
    task ensure_dates: :environment do
      Task.where("status in (?)", [:completed, :in_progress]).where(start_date: nil).each do |task|
        task.update_attribute(:start_date, Iteration.new(task.project.team).start_date) if task.start_date.blank?
      end
      Task.where(status: :completed).where(completed_date: nil).each do |task|
        task.update_attribute(:completed_date, Iteration.new(task.project.team).start_date) if task.completed_date.blank?
      end
    end

    desc 'Reset task ranks'
    task reset_ranks: :environment do
      tasks = Task.for_iteration(DateTime.now - 5.years)
      status = :completed
      rank = 0
      tasks.each do |task|
        task.update_column(:rank, rank)
        rank = task.status != status ? 0 : rank + 1
        status = task.status
      end
    end

  end

end
