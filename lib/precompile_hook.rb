# // TODO: Move to mumukit
class MultiFilePrecompileHook < Mumukit::Hook
  def compile(request)
    files = files_of request
    content = files.empty? ? single_file_content(request) : multi_file_content(files)

    struct request.to_h.merge content: content
  end

  def main_file
    raise NotImplementedError
  end

  def consolidate(main_content, files)
    raise NotImplementedError
  end

  def single_file_content(request)
    request.content
  end

  def multi_file_content(files)
    return files.values.first if files.count == 1

    consolidate(files[main_file] || '', files)
  end

  def files_of(request)
    request.to_stringified_h.select { |key, _| key.include? '.' }
  end
end

class HtmlPrecompileHook < MultiFilePrecompileHook
  VALID_EXTENSIONS = ['.html', '.js', '.css']

  def main_file
    'index.html'
  end

  def consolidate(main_content, files)
    files_by_extension = files.group_by { |file_name, _| file_name.get_extension }
    files_by_extension.each { |extension, values| files_by_extension[extension] = values.to_h }

    document = Nokogiri::HTML(main_content)
    merge_script_tags! document, files_by_extension
    merge_style_tags! document, files_by_extension
    document.to_html
  end

  def single_file_content(request)
    request.content.presence || request.extra
  end

  def files_of(request)
    super(request).select { |file_name, _|
      VALID_EXTENSIONS.any? { |extension| file_name.end_with? extension }
    }
  end

  private

  def merge_script_tags!(document, files_by_extension)
    document.xpath("//script").each { |tag|
      src = tag.get_attribute 'src'
      file = files_by_extension.dig('js', src)
      tag.replace("<script>#{file}</script>") if file.present?
    }
  end

  def merge_style_tags!(document, files_by_extension)
    document.xpath("//link").each { |tag|
      rel = tag.get_attribute 'rel'
      return if rel != 'stylesheet'

      href = tag.get_attribute 'href'
      file = files_by_extension.dig('css', src)
      tag.replace("<style>#{file}</style>") if file.present?
    }
  end
end
