class CssParser::Parser
  def tree
    to_h['all'].with_indifferent_access
  end
end

module Checker
  class CSS
    def self.run(document, expectation, binding)
      content = document.xpath('//style').text.presence || document.text
      inspection = expectation.inspection
      parser = CssParser::Parser.new
      parser.load_string! content
      raise "Unsopported inspection #{inspection.type}" unless ['DeclaresStyle', 'DeclaresStyle:'].include? inspection.type
      case inspection.target.to_s.split(':').size
        when 0 then inspect_selector(parser, inspection, binding)
        when 1 then inspect_property(parser, inspection, binding)
        when 2 then inspect_property_and_value(parser, inspection, binding)
        else raise "Malformed target value."
      end
    end

    def self.inspect_selector(parser, inspection, binding)
      parser.tree[binding.to_s].present?
    end

    def self.inspect_property(parser, inspection, binding)
      property, value = parse_target(inspection.target)
      parser.tree[binding.to_s][property].present?
    end
    def self.inspect_property_and_value(parser, inspection, binding)
      property, value = parse_target(inspection.target)
      parser.tree[binding.to_s][property] == value
    end

    def self.parse_target(target)
     target.to_s.split(':')
    end
  end
end
