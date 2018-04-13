module Checker
  class CSS
    def self.run(document, expectation, binding)
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
  end
end
