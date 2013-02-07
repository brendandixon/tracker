class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.role?(:admin)
      can :manage, [Role, User]
      can :read, [Category, Feature, Project, Story, Task, Team]
    end

    if user.role? :scrum_master
      can :manage, [Category, Feature, Project, Story, Task, Team]
      can :read, User
      can :edit, User, id: user.id
    end

    if user.role? :developer
      can :read, [Category, Feature, Project, Story, Task, Team, User]
      can [:create, :edit, :new, :update], Story
      can [:advance, :complete, :create, :edit, :new, :point, :print, :update], Task
      can :edit, User, id: user.id
    end

    if user.role? :observer
      can :read, [Category, Feature, Project, Story, Task, Team, User]
      can :print, Task
      can :edit, User, id: user.id
    end
  end
end
