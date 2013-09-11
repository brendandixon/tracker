class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.role?(:admin)
      can :manage, [Role, User]
      can :read, [Category, Feature, Project, Reference, ReferenceType, Story, Task, Team]
    end

    if user.role? :scrum_master
      can :manage, [Category, Feature, Project, Reference, ReferenceType, Story, Task, Team]
      can :read, User
      can [:edit, :update], User, id: user.id
    end

    if user.role? :developer
      can :manage, Task
      can :read, [Category, Feature, Project, Reference, ReferenceType, Story, Team, User]
      can [:create, :edit, :new, :update], [Reference, Story]
      can [:edit, :update], User, id: user.id
    end

    if user.role? :observer
      can :read, [Category, Feature, Project, Reference, ReferenceType, Story, Task, Team, User]
      can :print, Task
      can [:edit, :update], User, id: user.id
    end
  end
end
