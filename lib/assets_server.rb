class Mumukit::Server::App < Sinatra::Base
  include Mumukit::Server::WithAssets

  get_local_asset 'multiple-files.js', 'lib/render/multiple-files.js'
end
