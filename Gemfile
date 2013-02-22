source 'http://rubygems.org'

gem 'rails', '3.2.11'

# Gems for all enviroments
gem 'haml'
gem 'jquery-rails'
gem 'uuidtools'
# Mongo ODM - mongo_mapper
gem 'mongo_mapper'
gem 'bson_ext'
# Account management - devise
gem 'devise'
gem 'mm-devise'
# FB auth - omiauth-facebook
# gem 'omniauth-facebook'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails'
  gem 'sass-rails'
  gem 'uglifier'
  gem "therubyracer", :require => 'v8'
end

# Gems used only for production enviroment
group :production do
  # Ruby web server - thin
  gem 'thin'
end

# Gems used in development and testing
group :development, :test do
  #gem 'linecache19'
  #gem 'ruby-debug-base19'
  #gem 'ruby-debug19', :require => 'ruby-debug'
  gem 'database_cleaner'
  # User Stories and BDD - capybara and cucumber-rails
  gem 'capybara'
  # gem 'launchy'
  # Functional and unit testing - rspec-rails
  gem 'rspec-rails'
  # Code coverage - simplecov
  gem 'simplecov', :require => false
  # Mocks - factory_girl
  gem 'factory_girl'
end

group :test do
  gem 'cucumber-rails'
  # Autotesting with ZenTest
  gem 'ZenTest'
end
