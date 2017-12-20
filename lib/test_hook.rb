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

    if expected.visible_chars == actual.visible_chars
      [render_html(actual, expected), :passed]
    else
      [render_html(actual, expected), :failed]
    end
  end

  def render_html(actual, expected)
    "#{build_iframe 'Obtenido', actual}#{build_iframe 'Esperado', expected}"
  end

  def build_iframe(name, content)
    <<html
<br>
<strong>#{name}</strong>
<div class="mu-browser">
  <iframe srcdoc="#{content.gsub('"', '&quot;')}"></iframe>
</div>
html
  end

end
