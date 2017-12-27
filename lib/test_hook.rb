require 'mumukit/hook'

class String
  def visible_chars
    gsub(/\s+/, '').downcase
  end
end

class HtmlTestHook < Mumukit::Hook
  def compile(request)
    request
  end

  def run!(request)
    expected = request[:test]
    actual = request[:content]

    if contents_match?(expected, actual)
      [render_html(actual), :passed]
    else
      [render_fail_html(actual, expected), :failed]
    end
  end

  def contents_match?(expected, actual)
    hexp_without_blanks(expected) == hexp_without_blanks(actual)
  rescue
    expected == actual
  end

  def hexp_without_blanks(content)
    squeezed_content = ["\r", "\n", "\t"]
                         .reduce(content.strip) { |c, it| c.gsub(it, ' ') }
                         .squeeze(' ')
    hexp(squeezed_content)
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

  def page_title(content)
    title = hexp(content).to_dom&.xpath('//title')&.first&.text
    title.present? ? " data-title=\"#{title}\"" : ''
  end

  def build_iframe(content)
    <<html
<div class="mu-browser"#{page_title content} data-srcdoc="#{content.gsub('"', '&quot;')}">
</div>
html
  end

end
