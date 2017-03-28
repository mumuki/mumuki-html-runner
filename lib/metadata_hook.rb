class TextMetadataHook < Mumukit::Hook
  def metadata
    { language: {
        name: 'html',
        icon: { type: 'devicon', name: 'html' },
        extension: 'html',
        test_framework: {
            name: 'html',
            test_extension: 'html'
        }
    } }
  end
end
