module Checker
  class HTML
    def self.run(document, expectation, binding)
      document.xpath "#{compile_scope binding}//#{compile_html_target expectation.inspection}"
    end

    def self.compile_html_target(inspection)
      target = inspection.target
      raise 'Target is required' if target.blank?

      case inspection.type
        when 'DeclaresTag'       then target.value
        when 'DeclaresAttribute' then "@#{target.value}"
        else raise "Unsupported inspection #{inspection.type}"
      end
    end

    def self.compile_scope(binding)
      "//#{binding == '*' ? '' : binding}"
    end
  end
end
