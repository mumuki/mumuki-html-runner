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
      [render_html(actual), :passed]
    else
      [render_html(actual), :failed]
    end
  end

  def render_html(actual)
    "<br><div class=\"mu-browser\"><iframe srcdoc=\"#{actual.gsub('"', '\"')}\"></iframe></div>"
  end

end
