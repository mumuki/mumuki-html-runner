class String
  def escape_html
    ERB::Util.html_escape self
  end

  def get_extension
    self.split('.').last
  end
end
