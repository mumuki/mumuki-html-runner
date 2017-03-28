require 'mumukit/hook'

class String
  def visible_chars
    delete(' ').delete("\n").delete("\t")
  end
end

class HtmlTestHook < Mumukit::Hook
  def compile(request)
    request
  end

  def run!(request)
    expected = request[:content]
    actual = request[:test]

    if expected.visible_chars == actual.visible_chars
      ['', :passed]
    else
      ['', :failed]
    end
  end

end
