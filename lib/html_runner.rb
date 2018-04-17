require 'mumukit'
require 'yaml'
require 'nokogiri'
require 'hexp'
require 'css_parser'

I18n.load_translations_path File.join(__dir__, 'locales', '*.yml')

Mumukit.runner_name = 'html'
Mumukit.configure do |config|
  config.content_type = 'html'
  config.process_expectations_on_empty_content = true
  config.run_test_hook_on_empty_test = true
end

require_relative './metadata_hook'
require_relative './test_hook'
require_relative './checker'
require_relative './expectations_hook'
