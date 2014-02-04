module Html5Validators
  module ActionViewExtension
    def validation_active?
      object.class.ancestors.include?(ActiveModel::Validations) && (object.auto_html5_validation != false) && (object.class.auto_html5_validation != false)
    end
    def inject_required_field
        @options["required"] ||= object.attribute_required?(@method_name) if validation_active?
    end

    def inject_maxlength_field
        @options["maxlength"] ||= object.attribute_maxlength(@method_name) if validation_active?
    end

    def inject_minlength_field
        @options["data-minlength"] ||= object.attribute_minlength(@method_name) if validation_active?
    end

    def inject_dependent_validation
        @options["data-dependent-validation"] ||= object.attribute_dependent_validation(@method_name) if validation_active?
    end

    def inject_min_max
        return unless validation_active?
        @options["max"] ||= object.attribute_max(@method_name)
        @options["min"] ||= object.attribute_min(@method_name)
    end
  end
end if ActionPack::VERSION::STRING >= '4'


module ActionView
  module Helpers
    module FormHelper
      def form_for_with_auto_html5_validation_option(record, options = {}, &proc)
        record.auto_html5_validation = false if (options[:auto_html5_validation] == false) && (record.respond_to? :auto_html5_validation=)
        form_for_without_auto_html5_validation_option record, options, &proc
      end
      alias_method_chain :form_for, :auto_html5_validation_option
    end

    if ActionPack::VERSION::STRING >= '4'
      module Tags
        class Base #:nodoc:
          include Html5Validators::ActionViewExtension
        end

        class TextField
          def render_with_html5_attributes
            inject_required_field
            inject_maxlength_field
            inject_dependent_validation
            inject_minlength_field
            inject_min_max

            render_without_html5_attributes
          end
          alias_method_chain :render, :html5_attributes
        end

        class TextArea
          def render_with_html5_attributes
            inject_required_field
            inject_maxlength_field
            inject_minlength_field
            inject_min_max

            render_without_html5_attributes
          end
          alias_method_chain :render, :html5_attributes
        end

        #TODO probably I have to add some more classes here
        [RadioButton, CheckBox, Select, DateSelect, TimeZoneSelect].each do |kls|
          kls.class_eval do
            def render_with_html5_attributes
              inject_required_field
              render_without_html5_attributes
            end
            alias_method_chain :render, :html5_attributes
          end
        end
      end
    # ActionPack::VERSION::STRING == '3'
    else
      class InstanceTag
        def to_input_field_tag_with_html5_attributes(field_type, options = {})
          if object.class.ancestors.include?(ActiveModel::Validations) && (object.auto_html5_validation != false) && (object.class.auto_html5_validation != false)
            options["required"] ||= object.attribute_required?(method_name)
            options["maxlength"] ||= object.attribute_maxlength(method_name)
            options["max"] ||= object.attribute_max(method_name)
            options["min"] ||= object.attribute_min(method_name)
          end
          to_input_field_tag_without_html5_attributes field_type, options
        end
        alias_method_chain :to_input_field_tag, :html5_attributes

        def to_text_area_tag_with_html5_attributes(options = {})
          if object.class.ancestors.include?(ActiveModel::Validations) && (object.auto_html5_validation != false) && (object.class.auto_html5_validation != false)
            options["required"] ||= object.attribute_required?(method_name)
            options["maxlength"] ||= object.attribute_maxlength(method_name)
          end
          to_text_area_tag_without_html5_attributes options
        end
        alias_method_chain :to_text_area_tag, :html5_attributes

        def to_radio_button_tag_with_html5_attributes(tag_value, options = {})
          if object.class.ancestors.include?(ActiveModel::Validations) && (object.auto_html5_validation != false) && (object.class.auto_html5_validation != false)
            options["required"] ||= object.attribute_required?(method_name)
          end
          to_radio_button_tag_without_html5_attributes tag_value, options
        end
        alias_method_chain :to_radio_button_tag, :html5_attributes

        def to_check_box_tag_with_html5_attributes(options = {}, checked_value = "1", unchecked_value = "0")
          if object.class.ancestors.include?(ActiveModel::Validations) && (object.auto_html5_validation != false) && (object.class.auto_html5_validation != false)
            options["required"] ||= object.attribute_required?(method_name)
          end
          to_check_box_tag_without_html5_attributes options, checked_value, unchecked_value
        end
        alias_method_chain :to_check_box_tag, :html5_attributes
      end
    end
  end
end
