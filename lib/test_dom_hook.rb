class Hexp::Node
  def flat_map_children(&blk)
    H[tag, attributes, children.flat_map(&blk)]
  end
end

class HtmlTestDomHook < Mumukit::Hook
  def compile(request)
    request
  end

  def run!(request)
    options = request.options
    expected = expected_html request
    actual = compile_content request

    if is_dom_ok expected, actual, options
      [render_html(actual), :passed]
    else
      [render_fail_html(actual, expected), :failed]
    end
  end

  private

  def is_dom_ok(expected, actual, options)
    expected.blank? || contents_match?(expected, actual, options)
  end

  def contents_match?(expected, actual, options)
    comparable_hexp(expected, options) == comparable_hexp(actual, options)
  rescue
    expected == actual
  end

  def comparable_hexp(content, options)
    content = squeeze_inner_whitespaces content unless options['keep_inner_whitespaces']
    exp = hexp content
    exp = exp.replace('script') { [] } if options['output_ignore_scripts']
    exp = exp.replace('style') { [] } if options['output_ignore_styles']
    exp = remove_outer_whitespaces exp unless options['keep_outer_whitespaces']
    exp
  end

  def remove_outer_whitespaces(hexp)
    hexp.flat_map_children do |node|
      next remove_outer_whitespaces(node) unless node.text?
      [node.strip.presence].compact
    end
  end

  def squeeze_inner_whitespaces(content)
    %W(\r \n \t)
        .reduce(content.strip) { |c, it| c.gsub(it, ' ') }
        .squeeze(' ')
  end

  def hexp(content)
    Hexp.parse("<html>#{content}</html>")
  end

  def render_html(actual)
    build_iframe actual
  end

  def render_fail_html(actual, expected)
    "#{build_result :actual, actual}#{build_result :expected, expected}"
  end

  def build_result(name, content)
    <<html
<br>
<strong>#{t name}</strong>
#{build_iframe content}
html
  end

  def page_title(dom)
    title = dom.xpath('//title').first&.text
    title.present? ? " data-title=\"#{title}\"" : ''
  end

  def page_favicon(dom)
    dom.xpath("//link[@rel='icon' and @href]").first
      .try { |tag| " data-favicon=\"#{tag['href']}\"" }
  end

  def build_iframe(content)
    dom = hexp(content).to_dom
    <<html
<div class="mu-browser"#{page_title dom}#{page_favicon dom} data-srcdoc="#{content.escape_html}">
</div>
html
  end

  def compile_content(request)
    request.extra.presence || request.content
  end

  def expected_html(request)
    request.test.is_a?(Hash) ? request.test['output'] : request.test
  end
end
