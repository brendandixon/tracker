module StatusScopes
  extend ActiveSupport::Concern

  STARTED = [:completed, :in_progress]
  INCOMPLETE = [:pending, :in_progress]
  COMPLETED = [:completed]

  ALL_STATES = (STARTED + INCOMPLETE + COMPLETED).flatten.uniq

  included do  
    scope :in_state, lambda{|status| where('tasks.status IN (?)', status)}
    
    scope :started, in_state(StatusScopes::STARTED)
    scope :incomplete, in_state(StatusScopes::INCOMPLETE)

    scope :pending, in_state(:pending)
    scope :in_progress, in_state(:in_progress)
    scope :completed, in_state(StatusScopes::COMPLETED)
  end

  class<<self

    def cleanse(*states)
      states.find_all{|state| ALL_STATES.include?(state)}
    end

  end

end
