class HtmlMetadataHook < Mumukit::Hook
  def metadata
    {
      language: {
        name: 'html',
        icon: {type: 'devicon', name: 'html'},
        extension: 'html',
        ace_mode: 'html',
        graphic: true
      },
        test_framework: {
        name: 'html',
        test_extension: 'html'
      },
      layout_assets_urls: {
        js: [
          'assets/multiple-files.js'
        ]
      }
    }
  end
end
