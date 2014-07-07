module Html5Validators
    module ActionViewExtension
        def validation_active?
            object.class.ancestors.include?(ActiveModel::Validations) && (object.auto_html5_validation != false) && (object.class.auto_html5_validation != false)
        end

        def html_options
            @html_options || @options
        end

        def inject_required_field
            html_options["required"] ||= object.attribute_required?(@method_name) if validation_active?
        end

        def inject_readonly_field
            html_options["readonly"] ||= object.attribute_readonly?(@method_name) if validation_active?
        end

        def inject_maxlength_field
            html_options["maxlength"] ||= object.attribute_maxlength(@method_name) if validation_active?
        end

        def inject_minlength_field
            raise "Pattern already defined, cannot inject minlength pattern" unless html_options["pattern"].blank?
            html_options["pattern"] ||= ".{#{object.attribute_minlength(@method_name)},}" if validation_active? and !object.attribute_minlength(@method_name).blank?
        end

        def inject_dependent_validation
            html_options["data-dependent-validation"] ||= object.attribute_dependent_validation(@method_name) if validation_active?
        end

        def inject_min_max
            return unless validation_active?
            html_options["max"] ||= object.attribute_max(@method_name)
            html_options["min"] ||= object.attribute_min(@method_name)
        end
    end
end

module ActionView
    module Helpers
        module FormHelper
            def form_for_with_auto_html5_validation_option(record, options = {}, &proc)
                record.auto_html5_validation = false if (options[:auto_html5_validation] == false) && (record.respond_to? :auto_html5_validation=)
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
                    inject_required_field
                    inject_readonly_field
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
                    inject_readonly_field
                    inject_maxlength_field
                    inject_minlength_field
                    inject_min_max

                    render_without_html5_attributes
                end
                alias_method_chain :render, :html5_attributes
            end

            #TODO probably I have to add some more classes here
            [RadioButton, CheckBox, Select, CollectionSelect, DateSelect, TimeZoneSelect].each do |kls|
                kls.class_eval do
                    def render_with_html5_attributes
                        inject_required_field
                        inject_readonly_field

                        render_without_html5_attributes
                    end
                    alias_method_chain :render, :html5_attributes
                end
            end
        end
    end
end
