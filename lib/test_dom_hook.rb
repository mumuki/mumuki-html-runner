class HtmlTestDomHook < Mumukit::Hook
  def compile(request)
    request
  end

  def run!(request)
    expected = expected_html request
    actual = compile_content request

    if is_dom_ok expected, actual
      [render_html(actual), :passed]
    else
      [render_fail_html(actual, expected), :failed]
    end
  end

  private

  def is_dom_ok(expected, actual)
    expected.blank? || contents_match?(expected, actual)
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