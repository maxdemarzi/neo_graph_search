neo_graph_search
================

A POC at replicating Facebook Graph Search with Cypher and Neo4j

Pre-Requisites
--------------

* You will need to get a Facebook Consumer Key and Secret on https://developers.facebook.com/apps
* Select the "user_likes", "user_location", "friends_likes", "friends_location" permissions.
* Under "Select how your app integrates with Facebook" click "Website with Facebook Login" and fill in "http://localhost:5000/"
* You will need Neo4j in order for your database.
* You will need Redis in order to use Sidekiq for background jobs.

Installation
----------------

    git clone git@github.com:maxdemarzi/neo_graph_search.git
    bundle install (run gem install bundler if you don't have bundler install)
    sudo apt-get install redis-server or brew install redis or install redis manually
    rake neo4j:install['enterprise','1.9.M04']
    rake neo4j:start
    rake neo4j:create
    export SESSION_SECRET=<your session secret> (anything will do, or skip it)
    export FACEBOOK_APP_ID=<your facebook app id>
    export FACEBOOK_SECRET=<your facebook app secret>
    export REDISTOGO_URL="redis://127.0.0.1:6379/"
    foreman start

On Heroku
---------

    git clone git@github.com:maxdemarzi/neosocial.git
    heroku apps:create neosocial
    heroku config:add SESSION_SECRET=<your session secret>
    heroku config:add FACEBOOK_APP_ID=<your facebook app id>
    heroku config:add FACEBOOK_SECRET=<your facebook secret>
    heroku addons:add neo4j
    heroku addons:add redistogo
    git push heroku master
    heroku ps:scale worker=1
    heroku run rake neo4j:create

See it running live at http://neographsearch.heroku.com
