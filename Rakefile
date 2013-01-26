require 'neography/tasks'
require 'neography'

namespace :neo4j do
  task :create do
    neo = Neography::Rest.new(ENV['NEO4J_URL'] || "http://localhost:7474")
    neo.create_node_index("people", "fulltext")
    neo.create_node_index("things", "fulltext")
    neo.create_node_index("places", "fulltext")        
  end
end