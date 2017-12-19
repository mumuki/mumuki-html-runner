class HtmlExpectationsHook < Mumukit::Hook
  def compile(request)
    request
  end

  def run!(request)
    document = Nokogiri::HTML(request.content)
    request.expectations.map do |expectation|
      expectation = Mumukit::Inspection::Expectation.parse(expectation)
      [[expectation.to_h, document.xpath(expectation.scope).inner_html == expectation.target]]
    end
  end
end
