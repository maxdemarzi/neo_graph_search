web: bundle exec thin start -p $PORT
worker: bundle exec sidekiq -c 20 -r ./lib/ngs.rb