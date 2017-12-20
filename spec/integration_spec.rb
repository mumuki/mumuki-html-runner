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
<br>
<strong>Obtenido</strong>
<div class="mu-browser">
  <iframe srcdoc="<meta charset=&quot;UTF-8&quot;>"></iframe>
</div>
<br>
<strong>Esperado</strong>
<div class="mu-browser">
  <iframe srcdoc="<meta charset=&quot;UTF-8&quot;>"></iframe>
</div>
html
                                expectation_results: [] }
  end


  context 'when code is different' do
    let(:test) { {content: '<html></html>',
                  test: '<html>'} }

    it { expect(response.except(:result)).to eq response_type: :unstructured,
                                                test_results: [],
                                                status: :failed,
                                                feedback: '',
                                                expectation_results: [] }
  end

  context 'when code is blank' do
    let(:test) { {content: '',
                  test: '<html></html>'} }

    it { expect(response).to eq response_type: :unstructured,
                                test_results: [],
                                status: :failed,
                                feedback: '',
                                result: <<html,
<br>
<strong>Obtenido</strong>
<div class="mu-browser">
  <iframe srcdoc=""></iframe>
</div>
<br>
<strong>Esperado</strong>
<div class="mu-browser">
  <iframe srcdoc="<html></html>"></iframe>
</div>
html
                                expectation_results: [] }
  end

  context 'when code has extra spaces' do
    let(:test) { {content: '<html></html>',
                  test: '<html> </html>'} }

    it { expect(response.except(:result)).to eq response_type: :unstructured,
                                                test_results: [],
                                                status: :passed,
                                                feedback: '',
                                                expectation_results: [] }
  end

  context 'when code has extra new-lines' do
    let(:test) { {content: '<html></html>',
                  test: "<html>\n</html>"} }

    it { expect(response).to eq response_type: :unstructured,
                                test_results: [],
                                status: :passed,
                                feedback: '',
                                result: <<html,
<br>
<strong>Obtenido</strong>
<div class="mu-browser">
  <iframe srcdoc="<html></html>"></iframe>
</div>
<br>
<strong>Esperado</strong>
<div class="mu-browser">
  <iframe srcdoc="<html>
</html>"></iframe>
</div>
html
                                expectation_results: [] }
  end
end
