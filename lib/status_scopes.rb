module StatusScopes
  extend ActiveSupport::Concern

  COMPLETED = [:completed]
  INCOMPLETE = [:pending, :in_progress]
  STARTED = [:completed, :in_progress]
  LEGAL_STATES = INCOMPLETE + COMPLETED
  ALL_STATES = [:complete, :incomplete] + INCOMPLETE + COMPLETED

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

    def legalize(*states)
      states.find_all{|state| LEGAL_STATES.include?(state)}
    end

    def map(*states)
      cleanse(*states).map do |state|
        case state
        when :complete then COMPLETED
        when :incomplete then INCOMPLETE
        when :started then STARTED
        end
      end.flatten.uniq
    end

  end

end
