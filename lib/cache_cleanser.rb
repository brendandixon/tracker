module CacheCleanser
  extend ActiveSupport::Concern

  included do
    after_save :refresh_cache
  end

  def refresh_cache
    self.class.refresh_cache
  end

end
