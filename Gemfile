source 'https://rubygems.org'

gem 'bootstrap-sass', '~> 2.2.2.0'
gem 'haml'
gem 'mysql2'
gem 'rails', '3.2.11'
gem 'safe_yaml', git: 'git@github.com:dtao/safe_yaml.git', tag: '0.6.0'

group :development do
  gem 'capistrano'
  gem 'foreman'
  gem 'haml-rails'
  gem 'quiet_assets'
end

group :development, :test do
  gem 'active_record_query_trace'
  gem 'annotate'
  gem 'factory_girl_rails', '~> 4.0'
  gem 'rspec-rails', '~> 2.0'
  gem 'thin'
end

group :production do
  gem 'passenger'
end

group :assets do
  gem 'sass', '3.2.5'
  gem 'sass-rails', '3.2.5'
  gem 'coffee-rails'

  gem 'sprockets', '2.2.2'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'
# gem 'jquery-rails-cdn'
# gem 'jquery-ui-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# To use debugger
# gem 'debugger'
