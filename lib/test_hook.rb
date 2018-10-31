require_relative './test_script_hook'

class HtmlTestHook < Mumukit::Hook
  TEST_SCRIPT_HOOK = HtmlTestScriptHook.new

  def compile(request)
    TEST_SCRIPT_HOOK.compile request
  end

  def run!(request)
    test_script_results = TEST_SCRIPT_HOOK.run! request

    expected = expected_html request
    actual = compile_content request

    status = status expected, actual, test_script_results
    output = output(expected, actual)
    if test_script_results.blank?
      [output, status]
    else
      [test_script_results[1], output, status]
    end
  end

  private

  def status(expected, actual, test_script_results = nil)
    is_dom_ok = is_dom_ok(expected, actual) # TODO: Soportar testear scripts y no DOM
    are_scripts_ok = are_scripts_ok(test_script_results)

    is_dom_ok && are_scripts_ok ? :passed : :failed
  end

  def output(expected, actual)
    is_dom_ok(expected, actual) ? render_html(actual) : render_fail_html(actual, expected)
  end

  def is_dom_ok(expected, actual)
    expected.blank? || contents_match?(expected, actual)
  end

  def are_scripts_ok(results)
    results.blank? || results[0] == :passed
  end

  def contents_match?(expected, actual)
    hexp_without_blanks(expected) == hexp_without_blanks(actual)
  rescue
    expected == actual
  end

  def hexp_without_blanks(content)
    hexp %W(\r \n \t)
           .reduce(content.strip) { |c, it| c.gsub(it, ' ') }
           .squeeze(' ')
  end

  def hexp(squeezed_content)
    Hexp.parse("<html>#{squeezed_content}</html>")
  end

  def render_html(actual)
    build_iframe actual
  end

  def render_fail_html(actual, expected)
    "#{build_result :actual, actual}#{build_result :expected, expected}"
  end

  def build_result(name, content)
    <<html
<br>
<strong>#{t name}</strong>
#{build_iframe content}
html
  end

  def page_title(dom)
    title = dom.xpath('//title').first&.text
    title.present? ? " data-title=\"#{title}\"" : ''
  end

  def page_favicon(dom)
    dom.xpath("//link[@rel='icon' and @href]").first
      .try { |tag| " data-favicon=\"#{tag['href']}\"" }
  end

  def build_iframe(content)
    dom = hexp(content).to_dom
    <<html
<div class="mu-browser"#{page_title dom}#{page_favicon dom} data-srcdoc="#{content.escape_html}">
</div>
html
  end

  def compile_content(request)
    request.extra.presence || request.content
  end

  def expected_html(request)
    request.test.is_a?(Hash) ? request.test['output'] : request.test
  end
end
