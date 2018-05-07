source 'https://rubygems.org'

# Specify your gem's dependencies in pact.gemspec
gemspec
gem "pact-support", github: 'tucker-m/pact-support', tag: 'pr1.2'

if ENV['X_PACT_DEVELOPMENT']
  gem "pact-support", path: '../pact-support'
  gem "pact-mock_service", path: '../pact-mock_service'
end
