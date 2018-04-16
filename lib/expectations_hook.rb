class HtmlExpectationsHook < Mumukit::Hook
  def compile(request)
    request
  end

  def run!(request)
    document = Nokogiri::HTML(compile_content(request))
    request.expectations.map do |raw|
      expectation = Mumukit::Inspection::Expectation.parse(raw.with_indifferent_access)
      binding = expectation.binding.gsub(/(css:)|(html:)/, '')
      lang = expectation.binding.starts_with?('css:')? 'CSS' : 'HTML'
      matches = "Checker::#{lang}".constantize.run document, expectation, binding
      {expectation: raw, result: negate(expectation, matches)}
    end
  end

  private

  def compile_content(request)
    request.content.presence || request.extra
  end

  def negate(expectation, matches)
    expectation.inspection.negated? ? matches.blank? : matches.present?
  end
end
