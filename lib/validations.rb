module Validations
  extend ActiveSupport::Concern

  module ClassMetods

    private
    def _merge_attributes(attr_names)
      options = attr_names.extract_options!
      options.merge(:attributes => attr_names.flatten)
    end

  end
end

Dir[File.dirname(__FILE__) + "/validations/*.rb"].sort.each do |path|
  filename = File.basename(path)
  require "validations/#{filename}"
end
