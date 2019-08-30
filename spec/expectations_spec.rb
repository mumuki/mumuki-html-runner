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

  describe '* DeclaresTag:' do
    let(:code) { '<html><body><h1>Hello</h1></body></html>' }
    let(:expectations) { [
      {binding: '*', inspection: 'DeclaresTag:h1'},
      {binding: '*', inspection: 'DeclaresTag:title'} ] }

    it { expect(result).to eq [
        { expectation: {binding: '*', inspection: 'DeclaresTag:h1'}, result: true},
        { expectation: {binding: '*', inspection: 'DeclaresTag:title'}, result: false} ] }
  end

  describe 'div DeclaresTag:' do
    let(:code) { '<html><body><div><h1>Hello</h1></div><h2>World</h2></body></html>' }
    let(:expectations) { [
      {binding: 'div', inspection: 'DeclaresTag:h1'},
      {binding: 'body', inspection: 'DeclaresTag:h1'},
      {binding: 'div', inspection: 'DeclaresTag:h2'} ] }

    it { expect(result).to eq [
        { expectation: {binding: 'div', inspection: 'DeclaresTag:h1'}, result: true},
        { expectation: {binding: 'body', inspection: 'DeclaresTag:h1'}, result: true},
        { expectation: {binding: 'div', inspection: 'DeclaresTag:h2'}, result: false} ] }
  end

  describe 'a DeclaresAttribute:' do
    let(:code) { '<html><body><a src="https://mumuki.io">Mumuki</a></body></html>' }
    let(:expectations) { [
      {binding: 'a', inspection: 'DeclaresAttribute:alt'},
      {binding: 'a', inspection: 'DeclaresAttribute:src'} ] }

    it { expect(result).to eq [
        { expectation: {binding: 'a', inspection: 'DeclaresAttribute:alt'}, result: false},
        { expectation: {binding: 'a', inspection: 'DeclaresAttribute:src'}, result: true} ] }
  end

  describe 'div/a DeclaresAttribute:' do
    let(:code) { '<html><body><div><a src="https://mumuki.io">Mumuki</a></div><a alt="Github">Github</a></body></html>' }
    let(:expectations) { [
      {binding: 'div/a', inspection: 'DeclaresAttribute:alt'},
      {binding: 'div/a', inspection: 'DeclaresAttribute:src'} ] }

    it { expect(result).to eq [
        { expectation: {binding: 'div/a', inspection: 'DeclaresAttribute:alt'}, result: false},
        { expectation: {binding: 'div/a', inspection: 'DeclaresAttribute:src'}, result: true} ] }
  end

  describe 'body Not:DeclaresTag:' do
    let(:code) { '<html><body><h1>Hello</h1></body></html>' }
    let(:expectations) { [
        {binding: 'body', inspection: 'Not:DeclaresTag:h1'},
        {binding: 'body', inspection: 'Not:DeclaresTag:h2'}] }

    it { expect(result).to eq [
        { expectation: {binding: 'body', inspection: 'Not:DeclaresTag:h1'}, result: false},
        { expectation: {binding: 'body', inspection: 'Not:DeclaresTag:h2'}, result: true}] }
  end

  describe 'body DeclaresStyle' do
    let(:code) { "p, h2 {color: blue; font-size: 4px;} div.cuadrado circulo {background: red}" }
    let(:expectations) { [
        {binding: 'css:h2', inspection: 'DeclaresStyle'},
        {binding: 'css:div.cuadrado circulo', inspection: 'DeclaresStyle'} ] }

    it { expect(result).to eq [
        { expectation: {binding: 'css:h2', inspection: 'DeclaresStyle'}, result: true},
        { expectation: {binding: 'css:div.cuadrado circulo', inspection: 'DeclaresStyle'}, result: true} ] }
  end
  describe 'body DeclaresStyle:' do
    let(:code) { '<head> <style> p, h2 {color: blue; font-size: 4px;} div.cuadrado circulo {background: red} div.withBorder { border: 12px solid rgb(5, 5, 5); } div.withSpecificFont { font-family: "Lato", "Helvetica Neue", "Helvetica", "Arial", sans-serif; }</style> </head>'}
    let(:expectations) { [
        {binding: 'css:h2', inspection: 'DeclaresStyle:color'},
        {binding: 'css:h2', inspection: 'DeclaresStyle:color:red'},
        {binding: 'css:div.withBorder', inspection: 'DeclaresStyle:border:2px'},
        {binding: 'css:div.withBorder', inspection: 'DeclaresStyle:border:rgb(5, 5, 5)'},
        {binding: 'css:div.withBorder', inspection: 'DeclaresStyle:border:solid'},
        {binding: 'css:div.withSpecificFont', inspection: 'DeclaresStyle:font-family:"Lato", "Helvetica Neue", "Helvetica", "Arial", sans-serif'},
        {binding: 'css:div.cuadrado circulo', inspection: 'DeclaresStyle:background:red'},
        {binding: 'css:h2', inspection: 'DeclaresStyle:color:blue'}] }


    it { expect(result).to eq [
        { expectation: {binding: 'css:h2', inspection: 'DeclaresStyle:color'}, result: true},
        { expectation: {binding: 'css:h2', inspection: 'DeclaresStyle:color:red'}, result: false},
        { expectation: {binding: 'css:div.withBorder', inspection: 'DeclaresStyle:border:2px'}, result: false},
        { expectation: {binding: 'css:div.withBorder', inspection: 'DeclaresStyle:border:rgb(5, 5, 5)'}, result: true},
        { expectation: {binding: 'css:div.withBorder', inspection: 'DeclaresStyle:border:solid'}, result: true},
        { expectation: {binding: 'css:div.withSpecificFont', inspection: 'DeclaresStyle:font-family:"Lato", "Helvetica Neue", "Helvetica", "Arial", sans-serif'}, result: true},
        { expectation: {binding: 'css:div.cuadrado circulo', inspection: 'DeclaresStyle:background:red'}, result: true},
        { expectation: {binding: 'css:h2', inspection: 'DeclaresStyle:color:blue'}, result: true}] }
  end
end
