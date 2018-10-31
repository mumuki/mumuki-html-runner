class HtmlTestScriptHook < Mumukit::Templates::FileHook
  isolated false # TODO: Make it true and push the worker

  def compile(request)
    return request if script_test(request).blank?

    struct request.to_h.merge file: super(request)
  end

  def run!(request)
    return nil if script_test(request).blank?

    super request.file
  end

  def command_line(filename)
    "run-dom-tests #{filename}"
  end

  def compile_file_content(request)
    JSON.generate html: request.content,
                  tests: script_test(request)
  end

  def post_process_file(_file, result, status)
    report = JSON.parse(result)
    test_results = generate_test_results report
    [status, test_results]
  end

  private

  def generate_test_results(report)
    report['tests'].map { |it|
      [
        it['fullTitle'],
        it['err'].blank? ? :passed : :failed,
        it['err']&.dig('message') || ''
      ]
    }
  end

  def script_test(request)
    request.test['tests']
  end
end
