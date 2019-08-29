class CssParser::Parser
  def dig(*keys)
    to_h['all'].dig(*keys.map(&:to_s)) rescue {}
  end
end

class String
  # Avoids properties like rgb(5, 10, 15) to be split
  def css_values
    scan /\w+(?:\(.*\))?/
  end

  def comma_separated_words
    split(',').map(&:strip)
  end
end

module Checker
  class CSS
    COMMA_SEPARATED_INSPECTION_REGEX = /^([\w-]+\s*)(,\s*[\w-]+\s*)+$/

    def self.run(document, expectation, binding)
      content = document.xpath('//style').text.presence || document.text
      inspection = expectation.inspection
      parser = CssParser::Parser.new
      parser.load_string! content
      raise "Unsupported inspection #{inspection.type}" unless ['DeclaresStyle', 'DeclaresStyle:'].include? inspection.type
      inspect parser, inspection, binding
    end

    def self.inspect(parser, inspection, binding)
      case inspection.target.to_s.split(':').size
        when 0 then inspect_selector(parser, inspection, binding)
        when 1 then inspect_property(parser, inspection, binding)
        when 2 then inspect_property_and_value(parser, inspection, binding)
        else raise "Malformed target value."
      end
    end

    def self.inspect_selector(parser, inspection, binding)
      parser.dig(binding).present?
    end

    def self.inspect_property(parser, inspection, binding)
      property, _ = parse_target(inspection.target)
      parser.dig(binding, property).present?
    end

    def self.inspect_property_and_value(parser, inspection, binding)
      property, value = parse_target(inspection.target)
      actual_value = parser.dig(binding, property) || ''
      values_match? value, actual_value
    end

    def self.values_match?(inspection_value, actual_value)
      if inspection_value =~ COMMA_SEPARATED_INSPECTION_REGEX
        comma_separated_values_match? inspection_value, actual_value
      else
        actual_value.css_values.include? inspection_value
      end
    end

    def self.parse_target(target)
      target.to_s.split(':')
    end

    def self.comma_separated_values_match?(inspection_value, actual_value)
      inspection_value.comma_separated_words == actual_value.comma_separated_words
    end
  end
end
