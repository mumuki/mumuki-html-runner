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
      raise 'Target is required' if inspection.target.blank?
      case inspection.type
        when 'DeclaresTag'       then inspect_tag(parser, inspection)
        when 'DeclaresAttribute' then inspect_attribute(parser, inspection, binding)
        else raise "Unsupported inspection #{inspection.type}"
      end
    end

    def self.inspect_tag(parser, inspection)
      parser.tree[inspection.target.to_s].present?
    end

    def self.inspect_attribute(parser, inspection, binding)
      property, value = inspection.target.to_s.split(':')
      parser.tree[binding.to_s][property] == value
    end
  end
end
