module ActiveModel
  module Validations
    module HelperMethods
      def current_validators
        self.respond_to?(:validators) ? validators : self.class.validators
      end

      def current_object
        self.respond_to?(:validators) ? nil : self
      end

      def validator_match?(validator)
        return true if !validator.options.include?(:on) || !current_object

        case validator.options[:on]
        when :save
          true
        when :create
          !current_object.persisted?
        when :update
          current_object.persisted?
        end
      end

      def attribute_required?(attribute)
        current_validators.grep(PresenceValidator).any? do |v|
          validator_match?(v) && v.attributes.include?(attribute.to_sym) && (v.options.keys & [:if, :unless]).empty?
        end ||
          attribute.to_s.end_with?('_confirmation') && self.attribute_required?(attribute.to_s.sub(/_confirmation$/, '').to_sym) # hacky but works?
      end

      def attribute_readonly?(attribute)
        !current_object || !current_object.new_record? && current_object.class._attr_readonly.include?(attribute.to_s)
      end

      def attribute_maxlength(attribute)
        current_validators.grep(LengthValidator).select do|v|
          validator_match?(v) && v.attributes.include?(attribute.to_sym) && (v.options.keys & [:maximum, :is]).any? && (v.options.keys & [:if, :unless]).empty?
        end.map { |v| v.options.slice(:maximum, :is) }.map(&:values).flatten.max
      end

      def attribute_minlength(attribute)
        current_validators.grep(LengthValidator).select do|v|
          validator_match?(v) && v.attributes.include?(attribute.to_sym) && (v.options.keys & [:minimum, :is]).any? && (v.options.keys & [:if, :unless]).empty?
        end.map { |v| v.options.slice(:minimum, :is) }.map(&:values).flatten.min
      end

      def attribute_max(attribute)
        current_validators.grep(NumericalityValidator).select do|v|
          validator_match?(v) && v.attributes.include?(attribute.to_sym) && (v.options.keys & [:less_than, :less_than_or_equal_to]).any? && (v.options.keys & [:if, :unless]).empty?
        end.map { |v| v.options.slice(:less_than, :less_than_or_equal_to) }.map(&:values).flatten.max
      end

      def attribute_min(attribute)
        current_validators.grep(NumericalityValidator).select do|v|
          validator_match?(v) && v.attributes.include?(attribute.to_sym) && (v.options.keys & [:greater_than, :greater_than_or_equal_to]).any? && (v.options.keys & [:if, :unless]).empty?
        end.map { |v| v.options.slice(:greater_than, :greater_than_or_equal_to) }.map(&:values).flatten.min
      end

      def attribute_dependent_validation(attribute)
        "#{current_object.class.to_s.underscore}_#{attribute.to_s.sub(/_confirmation$/, '')}" if current_object && attribute.to_s.end_with?('_confirmation')
      end
    end
  end
end
