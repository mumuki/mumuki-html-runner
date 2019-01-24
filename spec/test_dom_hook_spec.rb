require_relative 'spec_helper'

describe HtmlTestDomHook do
  subject { HtmlTestDomHook.new }

  def expect_comparable_html_to_eq(original, expected, options = {})
    expect(subject.send(:comparable_hexp, original, options).to_html).to eq expected
  end

  it { expect_comparable_html_to_eq '<div> </div>', '<html><body><div></div></body></html>' }
  it { expect_comparable_html_to_eq '<html></html>', '<html></html>' }
  it { expect_comparable_html_to_eq "<html><body><p> hello world </p></body></html>", '<html><body><p>hello world</p></body></html>' }

  it { expect_comparable_html_to_eq "<html><body><p>      hello     world     </p></body></html>", '<html><body><p>hello world</p></body></html>' }
  it { expect_comparable_html_to_eq "<html><body><p>      hello\t\tworld     </p></body></html>", '<html><body><p>hello world</p></body></html>' }

  it { expect_comparable_html_to_eq "<html><body><p>      hello\t\tworld     </p></body></html>",
                                    "<html><body><p>hello\t\tworld</p></body></html>",
                                    'keep_inner_whitespaces' => true }

  it { expect_comparable_html_to_eq "<html><body><p>      hello\t\tworld     </p></body></html>",
                                    "<html><body><p> hello world </p></body></html>",
                                    'keep_outer_whitespaces' => true }

  it { expect_comparable_html_to_eq "<html><body><p>      hello\t\tworld     </p></body></html>",
                                    "<html><body><p>      hello\t\tworld     </p></body></html>",
                                    'keep_inner_whitespaces' => true,
                                    'keep_outer_whitespaces' => true }

  it { expect_comparable_html_to_eq "<html><body><p>\n\n      hello\n     world     </p></body></html>", '<html><body><p>hello world</p></body></html>' }
  it { expect_comparable_html_to_eq " <html>  \n<body>  <p>hello</p></body></html>", '<html><body><p>hello</p></body></html>' }
end
