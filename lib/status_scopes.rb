module StatusScopes
  extend ActiveSupport::Concern

  COMPLETED = [:completed]
  INCOMPLETE = [:pending, :in_progress]
  STARTED = [:completed, :in_progress]
  LEGAL_STATES = INCOMPLETE + COMPLETED
  ALL_STATES = [:iteration, :complete, :incomplete] + INCOMPLETE + COMPLETED

  included do  
    scope :in_state, lambda{|status| where('tasks.status IN (?)', status)}
    
    scope :started, in_state(STARTED)
    scope :incomplete, in_state(INCOMPLETE)

    scope :pending, in_state(:pending)
    scope :in_progress, in_state(:in_progress)
    scope :completed, in_state(COMPLETED)
  end
end
