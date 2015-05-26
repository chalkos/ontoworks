port 3000
environment ENV['RAILS_ENV'] || 'development'
threads 3,16
preload_app!
quiet
