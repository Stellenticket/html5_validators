require 'rails'

module Html5Validators
  @enabled = true

  def self.enabled
    @enabled
  end

  def self.enabled=(enable)
    @enabled = enable
  end

  class Railtie < ::Rails::Railtie #:nodoc:
    config.to_prepare do
      Dir.glob(
        File.join(
          File.dirname(__FILE__),
          'html5_validators',
          'decorators',
          '**',
          '*_decorator.rb'
        )
      ).each do |c|
        require_dependency(c)
      end
    end

    initializer 'html5_validators' do |_app|
      ActiveSupport.on_load(:active_record) do
        require 'html5_validators/active_model/helper_methods'
        require 'html5_validators/active_model/validations'
        require 'html5_validators/active_record/base'
      end
      ActiveSupport.on_load(:action_view) do
        require 'html5_validators/action_view/form_helpers'
      end
    end
  end
end
