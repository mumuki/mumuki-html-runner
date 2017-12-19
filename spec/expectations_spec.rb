require_relative 'spec_helper'

describe HtmlExpectationsHook do
  def req(expectations, content)
    struct expectations: expectations, content: content
  end

  def compile_and_run(request)
    runner.run!(runner.compile(request))
  end

  let(:runner) { HtmlExpectationsHook.new }
  let(:result) { compile_and_run(req(expectations, code)) }

  describe '* Declares:' do
    let(:code) { '<html><body><h1>Hello</h1></body></html>' }
    let(:expectations) { [
        {binding: '*', inspection: 'Declares:Hello'},
        {binding: '*', inspection: 'Declares:Bar'}] }

    it { expect(result).to eq [
          { expectation: {binding: '*', inspection: 'Declares:Hello'}, result: true},
          { expectation: {binding: '*', inspection: 'Declares:Bar'}, result: false} ] }
  end

  describe '//h1 Declares:' do
    let(:code) { '<html><body><h1>Hello</h1></body></html>' }
    let(:expectations) { [
      {binding: '//h1', inspection: 'Declares:Hello'},
      {binding: '//title', inspection: 'Declares:Hello'} ] }

    it { expect(result).to eq [
        { expectation: {binding: '//h1', inspection: 'Declares:Hello'}, result: true},
        { expectation: {binding: '//title', inspection: 'Declares:Hello'}, result: false} ] }
  end

  describe '//h1 Declares' do
    let(:code) { '<html><body><h1>Hello</h1></body></html>' }
    let(:expectations) { [{binding: '//h1', inspection: 'Declares'}] }

    it { expect(result).to eq [
        { expectation: {binding: '//h1', inspection: 'Declares'}, result: true}] }
  end
end
