module FieldExtensions
  extend ActiveSupport::Concern

  module ClassMethods
    
    #--------------------------------------------------------------------------
    # Note:
    # - These extensions will not behave correctly with aliased fields
    # 
    #--------------------------------------------------------------------------
    
    # Ensure content is always a symbol
    def symbolize(*attrs)
      attrs.each do |attr|
        if self < ActiveRecord::Base || self < AttributesHelper
          class_eval <<-METHODS
            def #{attr}
              value = read_attribute(:#{attr})
              value.blank? ? nil : value.to_sym
            end
          
            def #{attr}=(value)
              write_attribute(:#{attr}, value.blank? ? nil : value.to_s.downcase)
            end
          METHODS
        elsif self < ActiveModel::Validations
          class_eval <<-METHODS
            def #{attr}
              @#{attr}.blank? ? nil : @#{attr}.to_sym
            end
          
            def #{attr}=(value)
              @#{attr} = value.blank? ? nil : value.to_s.downcase.to_sym
            end
          METHODS
        end
      end
    end
    
    # Ensure content contains upper-case strings
    def upperize(*attrs)
      attrs.each do |attr|
        if self < ActiveRecord::Base || self < AttributesHelper
          class_eval <<-METHODS
            def #{attr}=(value)
              write_attribute(:#{attr}, value.blank? ? nil : value.to_s.upcase)
            end
          METHODS
        elsif self < ActiveModel::Validations
          class_eval <<-METHODS
            def #{attr}=(value)
              @#{attr} = value.blank? ? nil : value.to_s.upcase
            end
          METHODS
        end
      end
    end

  end
  
end

ActiveModel::Validations.send(:include, FieldExtensions)
ActiveRecord::Base.send(:include, FieldExtensions)
