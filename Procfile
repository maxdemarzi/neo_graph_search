web: bundle exec thin start -p $PORT
worker: bundle exec sidekiq -c 4 -r ./lib/ngs.rb