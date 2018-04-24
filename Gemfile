source 'https://rubygems.org'

# Specify your gem's dependencies in pact.gemspec
gemspec
gem "pact-support", git: 'https://github.com/tucker-m/pact-support.git'

if ENV['X_PACT_DEVELOPMENT']
  gem "pact-mock_service", path: '../pact-mock_service'
end
