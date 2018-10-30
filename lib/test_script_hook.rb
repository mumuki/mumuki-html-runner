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
    "run-script-tests #{filename}"
  end

  def compile_file_content(request)
    "hola" # TODO: Implement
  end

  def post_process_file(_file, result, status)
    puts "EL RESULT ES", result
    result
  end

  private

  def script_test(request)
    request.test['tests']
  end
end
