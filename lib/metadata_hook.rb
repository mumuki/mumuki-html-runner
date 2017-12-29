class HtmlMetadataHook < Mumukit::Hook
  def metadata
    {language: {
      name: 'html',
      icon: {type: 'devicon', name: 'html'},
      extension: 'html',
      ace_mode: 'haskell',
      graphic: true
    },
     test_framework: {
       name: 'html',
       test_extension: 'html'
     }
    }
  end
end
