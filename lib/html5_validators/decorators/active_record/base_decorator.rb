module ActiveRecord
  Base.class_eval do
    def attribute_required?(attribute)
      self.class.validators.grep(Validations::PresenceValidator).any? do |v|
        v.attributes.include?(attribute.to_sym) && validate_condition_true?(v)
      end ||
        attribute.to_s.end_with?('_confirmation'.freeze) &&
          attribute_required?(attribute.to_s[0...-13].to_sym) # hacky but works?
    end

    private

    def validate_condition_true?(v)
      validate_option_on_true?(v) &&
        (!v.options.key?(:if) || v.options[:if].to_proc.call(self)) &&
        (!v.options.key?(:unless) || !v.options[:unless].to_proc.call(self))
    end

    def validate_option_on_true?(v)
      case v.options[:on]
      when nil, :save
        true
      when :create
        !persisted?
      when :update
        persisted?
      end
    end
  end
end
