web: bundle exec rails server
redis: redis-server
solr: bundle exec rake sunspot:solr:run
sidekiq: bundle exec sidekiq -C config/sidekiq.yml
solr-test: RAILS_ENV=test bundle exec rake sunspot:solr:run