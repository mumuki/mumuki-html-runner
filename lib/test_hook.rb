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
    hexp(expected) == hexp(actual)
  rescue
    expected == actual
  end

  def hexp(content)
    squeezed_content = ["\r", "\n", "\t"].reduce(content) { |c, it| c.gsub(it, ' ') }.squeeze(' ')
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

  def build_iframe(content)
    <<html
<div class="mu-browser">
  <iframe srcdoc="#{content.gsub('"', '&quot;')}"></iframe>
</div>
html
  end

end
