class HtmlExpectationsHook < Mumukit::Hook
  def compile(request)
    request
  end

  def run!(request)
    document = Nokogiri::HTML(request.content)
    request.expectations.map do |raw|
      expectation = Mumukit::Inspection::Expectation.parse(raw)
      matches = document.xpath "#{compile_scope expectation}//#{compile_target expectation.inspection}"
      {expectation: raw, result: negate(expectation, matches)}
    end
  end

  private

  def compile_target(inspection)
    target = inspection.target
    raise 'Target is required' if target.blank?

    case inspection.type
      when 'DeclaresTag'       then target.value
      when 'DeclaresAttribute' then "@#{target.value}"
      else raise "Unsupported inspection #{inspection.type}"
    end
  end

  def compile_scope(expectation)
    "//#{expectation.binding == '*' ? '' : expectation.binding}"
  end

  def negate(expectation, matches)
    expectation.inspection.negated? ? matches.blank? : matches.present?
  end
end
