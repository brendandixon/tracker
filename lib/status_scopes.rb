module StatusScopes
  extend ActiveSupport::Concern

  STARTED = ['completed', 'in_progress']
  INCOMPLETE = ['in_progress', 'pending']
  COMPLETED = ['completed']

  ALL_STATES = (STARTED + INCOMPLETE + COMPLETED).flatten.uniq
  SELECT_STATES = ['completed', 'incomplete', 'in_progress', 'pending']

  included do  
    scope :in_state, lambda{|status| where('tasks.status IN (?)', status)}
    scope :not_in_state, lambda{|status| where('tasks.status NOT IN (?)', status)}
    
    scope :started, in_state(StatusScopes::STARTED)
    scope :incomplete, in_state(StatusScopes::INCOMPLETE)

    scope :pending, in_state('pending')
    scope :in_progress, in_state('in_progress')
    scope :completed, in_state(StatusScopes::COMPLETED)
  end

  class<<self

    def all_states
      @all_states ||= [['-', '']] + StatusScopes::SELECT_STATES.map{|state| [state.to_s.titleize, state]}
    end

    def collapse(*states)
      states = states.flatten.sort
      case states
      when COMPLETED then ['completed']
      when INCOMPLETE then ['incomplete']
      else states
      end.flatten
    end

    def expand(*states)
      states.map do |s|
        s = s.to_s
        case s
        when 'completed' then COMPLETED
        when 'incomplete' then INCOMPLETE
        when 'in_progress', 'pending' then s
        else nil
        end
      end.compact.flatten
    end

    def invert(*states)
      ALL_STATES.reject{|status| states.include?(status)}
    end

  end

end
