require_relative './spec_helper'

require 'active_support/all'

describe 'integration test' do
  let(:bridge) { Mumukit::Bridge::Runner.new('http://localhost:4567') }
  let(:response) { bridge.run_tests!(test) }

  before(:all) do
    @pid = Process.spawn 'rackup -p 4567', err: '/dev/null'
    sleep 3
    I18n.locale = :en
  end

  after(:all) { Process.kill 'TERM', @pid }

  context 'when code is equal to expected' do
    let(:test) { {content: '<html></html>',
                  test: '<html></html>'} }

    it { expect(response.except(:result)).to eq response_type: :unstructured,
                                                test_results: [],
                                                status: :passed,
                                                feedback: '',
                                                expectation_results: [] }
  end

  context 'when code is equal to expected, but has trailing whitespaces' do
    let(:test) { {content: " <html></html> \n ",
                  test: '<html></html>'} }

    it { expect(response.except(:result)).to eq response_type: :unstructured,
                                                test_results: [],
                                                status: :passed,
                                                feedback: '',
                                                expectation_results: [] }
  end

    context 'when extra code is equal to expected' do
    let(:test) { {content: '<body></body>', extra: '<html>/*...content...*/</html>',
                  test: '<html><body></body></html>'} }

    it { expect(response.except(:result)).to eq response_type: :unstructured,
                                                test_results: [],
                                                status: :passed,
                                                feedback: '',
                                                expectation_results: [] }
  end


  context 'when using expectations only' do
    let(:test) { {
      content: '<html><body><h2>Hello</h2></body></html>',
      test: '',
      expectations: [
        {binding: '*', inspection: 'DeclaresTag:h1'},
        {binding: 'body', inspection: 'DeclaresTag:h2'}]} }

    it { expect(response.except(:result)).to eq response_type: :unstructured,
                                                test_results: [],
                                                status: :passed_with_warnings,
                                                feedback: '',
                                                expectation_results: [
                                                  {binding: '*', inspection: 'DeclaresTag:h1', result: :failed},
                                                  {binding: 'body', inspection: 'DeclaresTag:h2', result: :passed}] }
  end

  context 'when texts differ on whitespaces' do
    let(:test) { {
      content: "<!DOCTYPE html>\r\n<html>\r\n<head>\r\n  <title>Mi Currículum</title>\r\n  <meta charset=\"utf-8\">\r\n</head>\r\n<body>\r\n  <header>\r\n    <h1>Mi Currículum</h1>\r\n  </header>\r\n  <main>\r\n    <section>\r\n      <h3>Habilidades</h3>\r\n      <ul>\r\n        <li>Programación con objetos</li>\r\n        <li>Ruby</li>\r\n        <li>HTML</li>\r\n      </ul>\r\n    </section>\r\n  </main>\r\n</body>\r\n</html>",
      test: "<!DOCTYPE html>\n<html>\n<head>\n  <title>Mi Currículum</title>\n  <meta charset=\"utf-8\">\n</head>\n<body>\n  <header>\n    <h1>Mi Currículum</h1>\n  </header>\n  <main>\n    <section>\n      <h3>Habilidades</h3>\n      <ul>\n        <li>Programación con objetos</li>\n        <li>Ruby</li>\n        <li>HTML</li>\n      </ul>\n    </section>\n  </main>\n</body>\n</html>",
      expectations: []} }

    it { expect(response.except(:result)).to eq response_type: :unstructured,
                                                test_results: [],
                                                status: :passed,
                                                feedback: '',
                                                expectation_results: [] }
  end

  context 'when html are not well formed' do
    let(:test) { {
      content: "<head>\r\n  <title>Roberto Arlt: Los siete Locos</title>\r\n</head>\r\n<body>\r\n  <h1>Los Siete Locos</h1>\r\n  <h2>Capítulo 1</h2>\r\n  <h3>La sorpresa</h3>\r\n  Al abrir la puerta de emergencia...\r\n  ",
      test: "<head>\n  <title>Roberto Arlt: Los siete Locos</title>\n</head>\n<body>\n  <h1>Los Siete Locos</h1>\n  <h2>Capítulo 1</h2>\n  <h3>La sorpresa</h3>\n  Al abrir la puerta de emergencia...\n  \n  <h3>Estados de conciencia</h3>\n  Sabía que era un ladrón...\n</body>",
      expectations: []} }

    it { expect(response.except(:result)).to eq response_type: :unstructured,
                                                test_results: [],
                                                status: :failed,
                                                feedback: '',
                                                expectation_results: [] }
  end


  context 'when code is equal to expected but with different case' do
    let(:test) { {content: '<HTML></HTML>',
                  test: '<html></html>'} }

    it { expect(response.except(:result)).to eq response_type: :unstructured,
                                                test_results: [],
                                                status: :passed,
                                                feedback: '',
                                                expectation_results: [] }
  end

  context 'when code has doble quotes equal to expected' do
    let(:test) { {content: '<meta charset="UTF-8">',
                  test: '<meta charset="UTF-8">'} }

    it { expect(response).to eq response_type: :unstructured,
                                test_results: [],
                                status: :passed,
                                feedback: '',
                                result: <<html,
<div class="mu-browser" data-srcdoc="#{'<meta charset="UTF-8">'.escape_html}">
</div>
html
                                expectation_results: [] }
  end

  context 'when code has different quotemarks' do
    let(:test) { {content: '<meta charset=\'UTF-8\'>',
                  test: '<meta charset="UTF-8">'} }

    it { expect(response).to eq response_type: :unstructured,
                                test_results: [],
                                status: :passed,
                                feedback: '',
                                result: <<html,
<div class="mu-browser" data-srcdoc="#{"<meta charset='UTF-8'>".escape_html}">
</div>
html
                                expectation_results: [] }
  end

  context 'when a tag is not closed but code is semantically equal' do
    let(:test) { {content: '<p> some text',
                  test: '<p> some text</p>'} }

    it { expect(response.except(:result)).to eq response_type: :unstructured,
                                                test_results: [],
                                                status: :passed,
                                                feedback: '',
                                                expectation_results: [] }
  end

  context 'when code is semantically different' do
    let(:test) { {content: '<html></html>',
                  test: '<html><div></div></html>'} }

    it { expect(response.except(:result)).to eq response_type: :unstructured,
                                                test_results: [],
                                                status: :failed,
                                                feedback: '',
                                                expectation_results: [] }
  end

  context 'when code is blank' do
    let(:test) { {content: '',
                  test: '<html></html>'} }

    it { expect(response.except(:result)).to eq response_type: :unstructured,
                                                test_results: [],
                                                status: :passed,
                                                feedback: '',
                                                expectation_results: [] }
  end

  context 'when code is syntactically wrong' do
    let(:test) { {content: 'some text',
                  test: '<html></html>'} }

    it { expect(response.except(:result)).to eq response_type: :unstructured,
                                                test_results: [],
                                                status: :failed,
                                                feedback: '',
                                                expectation_results: [] }
  end

  context 'when code has extra spaces within tags' do
    let(:test) { {content: '<html      ></html>',
                  test: '<html></html>'} }

    it { expect(response.except(:result)).to eq response_type: :unstructured,
                                                test_results: [],
                                                status: :passed,
                                                feedback: '',
                                                expectation_results: [] }
  end

  context 'when code has an extra space between tags' do
    let(:test) { {content: '<html> </html>',
                  test: '<html></html>'} }

    it { expect(response.except(:result)).to eq response_type: :unstructured,
                                                test_results: [],
                                                status: :failed,
                                                feedback: '',
                                                expectation_results: [] }
  end

  context 'when code has repeated spaces' do
    let(:test) { {content: '<html>  </html>',
                  test: '<html> </html>'} }

    it { expect(response.except(:result)).to eq response_type: :unstructured,
                                                test_results: [],
                                                status: :passed,
                                                feedback: '',
                                                expectation_results: [] }
  end

  context 'when code has attributes in different order' do
    let(:test) { {content: '<a href="http://www.mumuki.io" class="btn">',
                  test: '<a class="btn" href="http://www.mumuki.io"'} }

    it { expect(response.except(:result)).to eq response_type: :unstructured,
                                                test_results: [],
                                                status: :passed,
                                                feedback: '',
                                                expectation_results: [] }
  end

  context 'when code has extra new-lines' do
    let(:test) { {content: "<html>\n</html>",
                  test: '<html></html>'} }

    it { expect(response).to eq response_type: :unstructured,
                                test_results: [],
                                status: :failed,
                                feedback: '',
                                result: <<html,
<br>
<strong>Actual</strong>
<div class="mu-browser" data-srcdoc="#{"<html>\n</html>".escape_html}">
</div>

<br>
<strong>Expected</strong>
<div class="mu-browser" data-srcdoc="#{'<html></html>'.escape_html}">
</div>

html
                                expectation_results: [] }
  end

  context 'when code has repeated new-lines' do
    let(:test) { {content: "<html>\n\n</html>",
                  test: "<html>\n</html>"} }

    it { expect(response).to eq response_type: :unstructured,
                                test_results: [],
                                status: :passed,
                                feedback: '',
                                result: <<html,
<div class="mu-browser" data-srcdoc="#{"<html>\n\n</html>".escape_html}">
</div>
html
                                expectation_results: [] }
  end

  context 'when html has title tag' do
    let(:test) { {content: '<html><head><title>my title</title><head></html>',
                  test: '<html><head><title>my title</title><head></html>'} }

    it { expect(response).to eq response_type: :unstructured,
                                test_results: [],
                                status: :passed,
                                feedback: '',
                                result: <<html,
<div class="mu-browser" data-title="my title" data-srcdoc="#{'<html><head><title>my title</title><head></html>'.escape_html}">
</div>
html
                                expectation_results: [] }
  end
  context 'when html has multiples title tag' do
    let(:test) { {content: '<html><head><title>my title</title><title>my title 2</title><head></html>',
                  test: '<html><head><title>my title</title><title>my title 2</title><head></html>'} }

    it { expect(response).to eq response_type: :unstructured,
                                test_results: [],
                                status: :passed,
                                feedback: '',
                                result: <<html,
<div class="mu-browser" data-title="my title" data-srcdoc="#{'<html><head><title>my title</title><title>my title 2</title><head></html>'.escape_html}">
</div>
html
                                expectation_results: [] }
  end
  context 'when html has favicon' do
    let(:test) { {content: '<html><head><link rel="icon" href="favicon.ico"><head></html>',
                  test: '<html><head><link rel="icon" href="favicon.ico"><head></html>'} }

    it { expect(response).to eq response_type: :unstructured,
                                test_results: [],
                                status: :passed,
                                feedback: '',
                                result: <<html,
<div class="mu-browser" data-favicon="favicon.ico" data-srcdoc="#{'<html><head><link rel="icon" href="favicon.ico"><head></html>'.escape_html}">
</div>
html
                                expectation_results: [] }
  end
  context 'when html has favicon and title' do
    let(:test) { {content: '<html><head><title>my title</title><link rel="icon" href="favicon.ico"><head></html>',
                  test: '<html><head><title>my title</title><link rel="icon" href="favicon.ico"><head></html>'} }

    it { expect(response).to eq response_type: :unstructured,
                                test_results: [],
                                status: :passed,
                                feedback: '',
                                result: <<html,
<div class="mu-browser" data-title="my title" data-favicon="favicon.ico" data-srcdoc="#{'<html><head><title>my title</title><link rel="icon" href="favicon.ico"><head></html>'.escape_html}">
</div>
html
                                expectation_results: [] }
  end

  context 'when content is empty expectations run' do
    let(:test) { {content: 'p {color: blue;}', extra: '<html><head><style>/*...content...*/</style></head></html>',
                  expectations: [
                    {binding: 'css:p', inspection: 'DeclaresStyle:color:blue'},
                    {binding: 'css:p', inspection: 'DeclaresStyle:color'}],
                  test: ''} }

    it { expect(response).to eq response_type: :unstructured,
                                test_results: [],
                                status: :passed,
                                result: <<html,
<div class="mu-browser" data-srcdoc="#{'<html><head><style>p {color: blue;}</style></head></html>'.escape_html}">
</div>
html
                                feedback: '',
                                expectation_results: [
                                  {binding: 'css:p', inspection: 'DeclaresStyle:color:blue', result: :passed},
                                  {binding: 'css:p', inspection: 'DeclaresStyle:color', result: :passed}] }
  end

  context 'when using expectations only' do
    let(:test) { {
      content: '<html><head><style>p {color: blue;}</style></head></html>',
      test: '',
      expectations: [
        {binding: 'css:p', inspection: 'DeclaresStyle:color'},
        {binding: 'css:p', inspection: 'DeclaresStyle:color:blue'}]} }

    it { expect(response).to eq response_type: :unstructured,
                                                test_results: [],
                                                status: :passed,
                                                feedback: '',
                                                result: <<html,
<div class="mu-browser" data-srcdoc="#{'<html><head><style>p {color: blue;}</style></head></html>'.escape_html}">
</div>
html
                                                expectation_results: [
                                                  {binding: 'css:p', inspection: 'DeclaresStyle:color', result: :passed},
                                                  {binding: 'css:p', inspection: 'DeclaresStyle:color:blue', result: :passed}] }
  end
  context 'when using wrong expectations only' do
    let(:test) { {
      content: '<html><head><style>p {color: blue;}</style></head></html>',
      test: '',
      expectations: [
        {binding: 'css:p', inspection: 'DeclaresStyle:color'},
        {binding: 'css:p', inspection: 'DeclaresStyle:color:red'}]} }

    it { expect(response).to eq response_type: :unstructured,
                                                test_results: [],
                                                status: :passed_with_warnings,
                                                feedback: '',
                                                result: <<html,
<div class="mu-browser" data-srcdoc="#{'<html><head><style>p {color: blue;}</style></head></html>'.escape_html}">
</div>
html
                                                expectation_results: [
                                                  {binding: 'css:p', inspection: 'DeclaresStyle:color', result: :passed},
                                                  {binding: 'css:p', inspection: 'DeclaresStyle:color:red', result: :failed}] }
  end
end
