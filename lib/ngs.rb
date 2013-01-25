# -*- encoding: utf-8 -*-
$:.unshift File.dirname(__FILE__)

require 'bundler'
Bundler.require(:default, (ENV["RACK_ENV"]|| 'development').to_sym)

Sidekiq.configure_server do |config|
  config.redis = { :url => ENV['REDISTOGO_URL'], :size => 10}
end

Sidekiq.configure_client do |config|
  config.redis = { :url => ENV['REDISTOGO_URL'] , :size => 10}
end

Koala.http_service.http_options = {
    :ssl => { :ca_file => "./cacert.pem" }
}

$neo_server = Neography::Rest.new

require 'ngs/models/user'
require 'ngs/models/thing'

require 'ngs/jobs/import_facebook_profile'
require 'ngs/jobs/import_friends'
require 'ngs/jobs/import_mutual_friends'

require 'ngs/parser/ngs_cypher'
require 'ngs/parser/parser'