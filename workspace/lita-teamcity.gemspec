Gem::Specification.new do |spec|
  spec.name          = 'lita-slack-teamcity'
  spec.version       = '0.1.0'
  spec.authors       = ['Stephen Copp']
  spec.email         = ['info@stephencopp.com']
  spec.description   = 'Lita Slack Teamcity Bot'
  spec.summary       = 'A bot to kick off Teamcity builds'
  spec.homepage      = 'https://github.com/scopp/lita-slack-teamcity'
  spec.metadata      = { 'lita_plugin_type' => 'handler' }

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  #spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'lita', '>= 4.6.0'
  spec.add_runtime_dependency 'curb' , '>= 0.9.3'
  spec.add_runtime_dependency 'eventmachine'
  spec.add_runtime_dependency 'faraday'
  spec.add_runtime_dependency 'faye-websocket', '>= 0.8.0'
  spec.add_runtime_dependency 'multi_json'
  spec.add_runtime_dependency 'nokogiri', '>= 1.6.8'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '>= 3.0.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rack-test'
end
