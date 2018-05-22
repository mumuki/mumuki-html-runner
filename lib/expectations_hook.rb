class HtmlExpectationsHook < Mumukit::Hook
  def compile(request)
    request
  end

  def run!(request)
    document = Nokogiri::HTML(compile_content(request))
    request.expectations.map do |raw|
      evaluate_expectation raw, document
    end
  end

  private

  def evaluate_expectation(raw, document)
    expectation = Mumukit::Inspection::Expectation.parse(raw.with_indifferent_access)
    binding = expectation.binding.gsub(/(css:)|(html:)/, '')
    matches = checker_for(expectation).run document, expectation, binding
    {expectation: raw, result: negate(expectation, matches)}
  end

  def checker_for(expectation)
    lang = expectation.binding.starts_with?('css:')? 'CSS' : 'HTML'
    "Checker::#{lang}".constantize
  end

  def compile_content(request)
    request.content.presence || request.extra
  end

  def negate(expectation, matches)
    expectation.inspection.negated? ? matches.blank? : matches.present?
  end
end
