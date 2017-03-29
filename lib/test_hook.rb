require 'mumukit/hook'

class String
  def visible_chars
    gsub(/\s+/, '')
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
      [render_html(actual), :passed]
    else
      [render_html(actual), :failed]
    end
  end

  def render_html(actual)
    "<br><iframe
        style=\"border-color: #e6e6e6; border-style: solid; border-width: thin; width: 100%;\"
        srcdoc=\"#{actual}\"></iframe>"
  end

end
