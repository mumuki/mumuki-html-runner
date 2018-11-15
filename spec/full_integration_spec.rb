require_relative './spec_helper'

require 'active_support/all'

describe 'full exercises (DOM & scripts) integration test' do
  let(:bridge) { Mumukit::Bridge::Runner.new('http://localhost:4567') }
  let(:response) { bridge.run_tests!(request) }

  before(:all) do
    @pid = Process.spawn 'rackup -p 4567', err: '/dev/null'
    sleep 3
    I18n.locale = :en
  end

  after(:all) { Process.kill 'TERM', @pid }

  context 'when testing both DOM and scripts' do
    let(:test) { <<TEST
/*<output#*/
<html>
  <head>
    <title>page title</title>
  </head>
  <body>
    <strong id="message">hello</strong>
  </body>
</html>
/*#output>*/

/*<tests#*/
it("modifies the main message", function() {
	oldDocument.querySelector("#message").innerHTML.should.be.eql("hello");
	document.querySelector("#message").innerHTML.should.be.eql("I changed it from JS!");
});

it("calls alert() saying hey", function() {
  _last_alert_message_.should.eql("Hey!!");
});
/*#tests>*/

/*<options#*/
output_ignore_scripts: true
/*#options>*/
TEST
  }

    context 'when everything is OK' do
      let(:request) { {
        content: <<CONTENT,
/*<index.html#*/
<html>
  <head>
    <title>page title</title>
  </head>
  <body>
    <strong id="message">hello</strong>
    <script src="foo.js"></script>
  </body>
</html>
/*#index.html>*/

/*<foo.js#*/
document.querySelector("#message").innerHTML = "I changed it from JS!";
alert("Hey!!");
/*#foo.js>*/
CONTENT
        test: test,
        expectations: [
          {binding: 'body', inspection: 'DeclaresTag:strong'}
        ]
      } }

      it { expect(response.except(:result)).to eq response_type: :mixed,
                                                  test_results: [
                                                    { title: 'modifies the main message', status: :passed, result: '' },
                                                    { title: 'calls alert() saying hey', status: :passed, result: '' },
                                                  ],
                                                  status: :passed,
                                                  feedback: '',
                                                  expectation_results: [
                                                    {binding: 'body', inspection: 'DeclaresTag:strong', result: :passed}
                                                  ] }
    end

    context 'when the tests dont pass but the DOM is OK' do
      let(:request) { {
        content: <<CONTENT,
/*<index.html#*/
<html>
  <head>
    <title>page title</title>
  </head>
  <body>
    <strong id="message">hello</strong>
    <script src="foo.js"></script>
  </body>
</html>
/*#index.html>*/

/*<foo.js#*/
document.querySelector("#message").innerHTML = "sarasa";
alert("Hey!!");
/*#foo.js>*/
CONTENT
        test: test,
        expectations: []
      } }

      it { expect(response.except(:result)).to eq response_type: :mixed,
                                                  test_results: [
                                                    { title: 'modifies the main message', status: :failed, result: "<pre>expected 'sarasa' to deeply equal 'I changed it from JS!'</pre>" },
                                                    { title: 'calls alert() saying hey', status: :passed, result: '' },
                                                  ],
                                                  status: :failed,
                                                  feedback: '',
                                                  expectation_results: [] }
    end

    context 'when the tests pass but the DOM is wrong' do
      let(:request) { {
        content: <<CONTENT,
/*<index.html#*/
<html>
  <head>
    <title>Solution to everyday problems</title>
  </head>
  <body>
    <strong id="message">hello</strong>
    <script src="foo.js"></script>
    <iframe width="560" height="315" src="https://www.youtube.com/embed/dQw4w9WgXcQ"></iframe>
  </body>
</html>
/*#index.html>*/

/*<foo.js#*/
document.querySelector("#message").innerHTML = "I changed it from JS!";
alert("Hey!!");
/*#foo.js>*/
CONTENT
        test: test,
        expectations: []
      } }

      it { expect(response.except(:result)).to eq response_type: :mixed,
                                                  test_results: [
                                                    { title: 'modifies the main message', status: :passed, result: '' },
                                                    { title: 'calls alert() saying hey', status: :passed, result: '' },
                                                  ],
                                                  status: :failed,
                                                  feedback: '',
                                                  expectation_results: [] }
      it { expect(response[:result]).to include '<strong>Expected</strong>' }
    end

    context 'when JS code is broken' do
      let(:request) { {
        content: <<CONTENT,
/*<index.html#*/
<html>
  <head>
    <title>Solution to everyday problems</title>
  </head>
  <body>
    <strong id="message">hello</strong>
    <script src="foo.js"></script>
  </body>
</html>
/*#index.html>*/

/*<foo.js#*/
document.querySelec!&
/*#foo.js>*/
CONTENT
        test: test,
        expectations: []
      } }

      it { expect(response.except(:result)).to eq response_type: :unstructured,
                                                  test_results: [],
                                                  status: :errored,
                                                  feedback: '',
                                                  expectation_results: [] }
      it { expect(response[:result]).to include 'Unexpected token !' }
    end
  end

  context 'when testing scripts only' do
    let(:test) { <<TEST
/*<tests#*/
it("modifies the main message", function() {
	oldDocument.querySelector("#message").innerHTML.should.be.eql("hello");
	document.querySelector("#message").innerHTML.should.be.eql("I changed it from JS!");
});
/*#tests>*/
TEST
    }

    context 'it works too' do
      let(:request) { {
        content: <<CONTENT,
/*<index.html#*/
<html>
  <body>
    <strong id="message">hello</strong>
    <script src="foo.js"></script>
  </body>
</html>
/*#index.html>*/

/*<foo.js#*/
document.querySelector("#message").innerHTML = "I changed it from JS!";
/*#foo.js>*/
CONTENT
        test: test,
        expectations: []
      } }

      it { expect(response.except(:result)).to eq response_type: :mixed,
                                                  test_results: [
                                                    { title: 'modifies the main message', status: :passed, result: '' }
                                                  ],
                                                  status: :passed,
                                                  feedback: '',
                                                  expectation_results: [] }
    end
  end
end
