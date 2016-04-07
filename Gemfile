# source 'https://rubygems.org'
source 'http://ruby.taobao.org/'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'i18n', github: 'svenfuchs/i18n' #fix bug I18n dependency.
gem 'rails', '4.0.4'
# gem 'rails-i18n', '~> 4.0.0'

# Use sqlite3 as the database for Active Record
gem 'sqlite3'
gem 'mysql2'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

gem 'haml-rails'

gem 'cells'

gem 'bootstrap-sass', '~> 3.1'

gem 'geocoder'

gem 'exception_notification'

gem 'actionpack-xml_parser'
gem 'nokogiri'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.1.2'

# Use unicorn as the app server
gem 'unicorn'

gem "devise", '~> 3.1.2'
gem 'devise-async'
gem "cancan", '~> 1.6.10'
gem "cancancan", '~> 1.8.2'
# gem "rolify"

gem "simple_form"
gem 'nested_form'
gem "font-awesome-rails"
gem 'inherited_resources'

gem 'fast-aes'

gem 'forem', :github => "radar/forem", :branch => "rails4"

gem 'kaminari'
gem 'carrierwave'
gem 'mini_magick'

gem 'sinatra', '>= 1.3.0', require: nil
gem 'sidekiq'

gem 'symbolize', '4.4.1'
gem 'ledermann-rails-settings', :require => 'rails-settings'

gem 'figaro'
gem 'rest-client'
gem 'faraday'
gem 'aasm', '~> 3.1.0'

gem 'sunspot_rails'
gem 'sunspot_solr'
gem 'progress_bar'

gem 'qiniu-rs'
gem 'carrierwave-qiniu'
# Use Capistrano for deployment
# gem 'capistrano', group: :development

gem "omniauth-wechat-oauth2"

gem 'ancestry'

#http://rny.io/rails/react/2014/07/31/reactjs-and-rails.html
#encapsulates the JSON serialization of ActiveRecord objects, A serializer will automatically be created when we use Rails generator the generate related resouce
#to create sample data in rake task
gem 'active_model_serializers'
gem 'ffaker'
gem 'react-rails', github: 'reactjs/react-rails'

# Use debugger
# gem 'debugger', group: [:development, :test]

group :development, :test do
  gem 'ruby-graphviz', :require => 'graphviz'
  gem 'rails-erd'
  gem 'thin'
  gem 'capistrano', "2.15.5", require: false
  gem 'rvm-capistrano', require: false
  gem "quiet_assets", "~> 1.0.2"
  gem 'pry'
  gem "pry-rails"
  gem 'pry-nav'
  gem 'binding_of_caller'
  gem 'debug_inspector'
  gem "better_errors", ">= 0.7.2"
  gem 'foreman'
  gem "letter_opener"
  gem 'bullet'
  gem 'capybara'
  gem 'capybara_minitest_spec'
  gem 'selenium'
end
