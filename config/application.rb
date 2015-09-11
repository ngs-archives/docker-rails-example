require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  Bundler.require(*Rails.groups(assets: %w(development test)))
end

module DockerRailsExample
  class Application < Rails::Application
    config.active_record.raise_in_transactional_callbacks = true
    config.generators do|g|
      g.fixture = true
      g.fixture_replacement :factory_girl
      g.helper false
      g.integration_tool = false
      g.javascripts false
      g.stylesheets false
      g.template_engine :slim
      g.test_framework :rspec, view_specs: false, helper_specs: false, fixture: true
    end
  end
end
