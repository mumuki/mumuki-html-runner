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

  context 'when using expectations only' do
    let(:test) { {
      content: '<html><body><h2>Hello</h2></body></html>',
      test: '',
      expectations: [
        {binding: '*', inspection: 'DeclaresTag:h1'},
        {binding: 'body', inspection: 'DeclaresTag:h2'}] } }

    it { expect(response.except(:result)).to eq response_type: :unstructured,
                                                test_results: [],
                                                status: :passed_with_warnings,
                                                feedback: '',
                                                expectation_results: [
                                                  {binding: '*', inspection: 'DeclaresTag:h1', result: :failed},
                                                  {binding: 'body', inspection: 'DeclaresTag:h2', result: :passed}] }
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
<div class="mu-browser">
  <iframe srcdoc="<meta charset=&quot;UTF-8&quot;>"></iframe>
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
<div class="mu-browser">
  <iframe srcdoc="<meta charset='UTF-8'>"></iframe>
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
                                                status: :failed,
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
<div class="mu-browser">
  <iframe srcdoc="<html>\n</html>"></iframe>
</div>

<br>
<strong>Expected</strong>
<div class="mu-browser">
  <iframe srcdoc="<html></html>"></iframe>
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
<div class="mu-browser">
  <iframe srcdoc="<html>\n\n</html>"></iframe>
</div>
html
                                expectation_results: [] }
  end
end
