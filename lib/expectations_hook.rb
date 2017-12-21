class HtmlExpectationsHook < Mumukit::Hook
  def compile(request)
    request
  end

  def run!(request)
    document = Nokogiri::HTML(request.content)
    request.expectations.map do |expectation|
      expectation = Mumukit::Inspection::Expectation.parse(expectation)

      base_xpath = "//#{expectation.binding == '*' ? '' : expectation.binding}"

      raise 'Target is required' if expectation.inspection.target.blank?

      case expectation.inspection.type
        when 'DeclaresTag'      then xpath = "#{base_xpath}//#{expectation.inspection.target.value}"
        when 'DeclaresAttribute' then xpath = "#{base_xpath}//@#{expectation.inspection.target.value}"
        else raise "Unsupported inspection #{expectation.inspection.type}"
      end

      result = document.xpath(xpath).present?
      result = !result if expectation.inspection.negated?

      {expectation: expectation.to_h, result: result}
    end
  end
end
