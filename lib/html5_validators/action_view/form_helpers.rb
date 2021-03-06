module Html5Validators
  module ActionViewExtension
    def validation_active?
      object.class.ancestors.include?(ActiveModel::Validations) &&
        (object.auto_html5_validation != false) &&
        (object.class.auto_html5_validation != false)
    end

    def html_options
      (@html_options || @options)
    end

    def html_option_exists?(option)
      html_options.key?(option.to_sym) || html_options.key?(option.to_s.freeze)
    end

    def inject_required_field
      return if html_option_exists?(:required)
      html_options[:required] = object.attribute_required?(@method_name)
    end

    def inject_readonly_field
      return if html_option_exists?(:readonly)
      html_options[:readonly] = object.attribute_readonly?(@method_name)
    end

    def inject_maxlength_field
      return if html_option_exists?(:maxlength)
      html_options[:maxlength] = object.attribute_maxlength(@method_name)
    end

    def inject_placeholder_asterix
      return if !html_option_exists?(:placeholder) ||
                !object.attribute_required?(@method_name) ||
                html_options[:placeholder].blank?
      html_options[:placeholder] = html_options[:placeholder].to_s + '*'
    end

    def inject_prompt_asterix
      return if @options[:prompt].blank? ||
                !object.attribute_required?(@method_name)
      @options[:prompt] = @options[:prompt].to_s + '*'
    end

    def inject_minlength_field
      if html_option_exists?(:pattern)
        fail 'Pattern already defined, cannot inject minlength pattern'
      end

      return if object.attribute_minlength(@method_name).blank?
      html_options[:pattern] = ".{#{object.attribute_minlength(@method_name)},}"
    end

    def inject_dependent_validation
      return if html_option_exists?('data-depentend-validation')
      html_options['data-dependent-validation'] =
        object.attribute_dependent_validation(@method_name)
    end

    def inject_min_max
      html_options[:max] =
        object.attribute_max(@method_name) unless html_option_exists?(:max)
      html_options[:min] =
        object.attribute_min(@method_name) unless html_option_exists?(:min)
    end
  end
end

module ActionView
  module Helpers
    module FormHelper
      def form_for_with_auto_html5_validation_option(record, options = {}, &proc)
        if record.respond_to?(:auto_html5_validation=)
          if !Html5Validators.enabled || (options[:auto_html5_validation] == false)
            record.auto_html5_validation = false
          end
        end
        form_for_without_auto_html5_validation_option record, options, &proc
      end
      alias_method_chain :form_for, :auto_html5_validation_option
    end

    module Tags
      class Base #:nodoc:
        include Html5Validators::ActionViewExtension
      end

      class TextField
        def render_with_html5_attributes
          if validation_active?
            inject_required_field
            inject_readonly_field
            inject_maxlength_field
            inject_dependent_validation
            inject_minlength_field
            inject_min_max
            inject_placeholder_asterix
          end

          render_without_html5_attributes
        end
        alias_method_chain :render, :html5_attributes
      end

      class TextArea
        def render_with_html5_attributes
          if validation_active?
            inject_required_field
            inject_readonly_field
            inject_maxlength_field
            inject_minlength_field
            inject_min_max
            inject_placeholder_asterix
          end

          render_without_html5_attributes
        end
        alias_method_chain :render, :html5_attributes
      end

      [Select,
       CollectionSelect].each do |kls|
        kls.class_eval do
          def render_with_html5_attributes
            if validation_active?
              inject_required_field
              inject_readonly_field
              inject_prompt_asterix
            end

            render_without_html5_attributes
          end
          alias_method_chain :render, :html5_attributes
        end
      end

      # TODO: probably I have to add some more classes here
      [RadioButton,
       CheckBox,
       DateSelect,
       TimeZoneSelect].each do |kls|
         kls.class_eval do
           def render_with_html5_attributes
             if validation_active?
               inject_required_field
               inject_readonly_field
             end

             render_without_html5_attributes
           end
           alias_method_chain :render, :html5_attributes
         end
       end
    end
  end
end
