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

    let(:request) { {
      content: <<CONTENT,
/*<index.html#*/
<html>
  <head>
    <title>page title</title>
    <script src="foo.js"></script>
  </head>
  <body>
    <strong id="message">hello</strong>
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


end
