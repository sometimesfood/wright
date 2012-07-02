require 'wright/util'

class Wright::Providers
  PROVIDER_DIR = File.expand_path('providers', File.dirname(__FILE__))

  Dir.chdir(PROVIDER_DIR) do
    Dir['*.rb'].each do |filename|
      classname = "#{Wright::Util.filename_to_classname(filename)}"
      autoload classname, File.expand_path(filename)
    end
  end
end
