require 'mumukit'
require 'yaml'

I18n.load_translations_path File.join(__dir__, 'locales', '*.yml')

Mumukit.runner_name = 'html'
Mumukit.configure do |config|
  config.content_type = 'html'
end

require_relative './metadata_hook'
require_relative './test_hook'
