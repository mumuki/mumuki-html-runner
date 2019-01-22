require_relative 'spec_helper'

describe HtmlTestDomHook do
  subject { HtmlTestDomHook.new }

  def expect_comparable_html_to_eq(original, expected)
    expect(subject.send(:comparable_hexp, original, {}).to_html).to eq expected
  end

  it { expect_comparable_html_to_eq '<div> </div>', '<html><body><div></div></body></html>' }
  it { expect_comparable_html_to_eq '<html></html>', '<html></html>' }
  it { expect_comparable_html_to_eq "<html><body><p> hello world </p></body></html>", '<html><body><p>hello world</p></body></html>' }
  it { expect_comparable_html_to_eq "<html><body><p>      hello     world     </p></body></html>", '<html><body><p>hello world</p></body></html>' }
  it { expect_comparable_html_to_eq "<html><body><p>\n\n      hello\n     world     </p></body></html>", '<html><body><p>hello world</p></body></html>' }
  it { expect_comparable_html_to_eq " <html>  \n<body>  <p>hello</p></body></html>", '<html><body><p>hello</p></body></html>' }
end
