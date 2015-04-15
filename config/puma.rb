port 3000
#environment ENV['RACK_ENV'] || 'development'
threads 0,16
preload_app!
quiet
