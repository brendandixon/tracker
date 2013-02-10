module ReferencesHandler
  extend ActiveSupport::Concern
  
  included do  
    before_filter :sanitize_references, only: [:create, :update]
  end

  def sanitize_references
    v = params[self.controller_name.singularize.underscore]
    return if v.blank?
    r = v['references_attributes']
    return if r.blank? || !r.is_a?(Array)
    r.delete_if {|h| h['value'].nil? || h['value'].blank?}
  end

end
