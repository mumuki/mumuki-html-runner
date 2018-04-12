class HtmlExpectationsHook < Mumukit::Hook
  def compile(request)
    request
  end

  def run!(request)
    document = Nokogiri::HTML(request.content)
    request.expectations.map do |raw|
      expectation = Mumukit::Inspection::Expectation.parse(raw.with_indifferent_access)
      binding = expectation.binding.gsub(/(css:)|(html:)/, '')
      lang = expectation.binding.starts_with?('css:')? 'css' : 'html'
      matches = send("run_#{lang}", document, expectation, binding)
      {expectation: raw, result: negate(expectation, matches)}
    end
  end

  private

  def run_css(document, expectation, binding)
    content = document.xpath('//style').text.presence || document.text
    inspection = expectation.inspection
    parser = CssParser::Parser.new
    parser.load_string! content
    target = inspection.target
    raise 'Target is required' if target.blank?
    case inspection.type
      when 'DeclaresTag'       then parser.to_h['all'][target.to_s].present?
      when 'DeclaresAttribute' then parser.to_h['all'][binding.to_s][target.to_s.split(':').first] == target.to_s.split(':').last
      else raise "Unsupported inspection #{inspection.type}"
    end
  end

  def run_html(document, expectation, binding)
    document.xpath "#{compile_scope binding}//#{compile_html_target expectation.inspection}"
  end

  def compile_html_target(inspection)
    target = inspection.target
    raise 'Target is required' if target.blank?

    case inspection.type
      when 'DeclaresTag'       then target.value
      when 'DeclaresAttribute' then "@#{target.value}"
      else raise "Unsupported inspection #{inspection.type}"
    end
  end

  def compile_scope(binding)
    "//#{binding == '*' ? '' : binding}"
  end

  def negate(expectation, matches)
    expectation.inspection.negated? ? matches.blank? : matches.present?
  end
end
