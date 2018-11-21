require_relative './test_dom_hook'
require_relative './test_script_hook'

class HtmlTestHook < Mumukit::Hook
  def initialize(config = nil)
    super config
    @dom_hook = HtmlTestDomHook.new
    @script_hook = HtmlTestScriptHook.new
  end

  def compile(request)
    request = struct request.to_h.merge options: options(request)
    @script_hook.compile @dom_hook.compile(request)
  end

  def run!(request)
    dom_output, dom_status = @dom_hook.run! request
    script_results = @script_hook.run!(request)
    script_test_results = script_results&.first
    return ["<pre>#{script_test_results}</pre>", :errored] if script_results&.last&.errored?

    if script_test_results.blank?
      [dom_output, dom_status]
    else
      [script_test_results, dom_output, dom_status]
    end
  end

  private

  def options(request)
    return {} unless request.test.is_a?(Hash)

    options_yaml = request.test['options']
    return {} if options_yaml.blank?

    YAML.load(options_yaml)
  end
end
