module Job
  class ImportFacebookProfile
    include Sidekiq::Worker
    sidekiq_options :retry => false

    def perform(uid)
      user = User.find_by_uid(uid)
      if user
        profile = user.client.get_object("me")
        
        if profile["location"]
          loc_id = profile["location"]["id"]
          loc_name = profile["location"]["name"]
          loc = $neo_server.create_unique_node("location_index", "uid", loc_id,
                                                {"name"      => loc_name,
                                                 "uid"       => loc_id
                                                })
          loc_node_id = loc["self"].split('/').last.to_i
          $neo_server.add_node_to_index("places", "name", loc_name, loc_node_id)                                          
          $neo_server.create_unique_relationship("lives_index", "user_place","#{profile["id"]}-#{loc_id}", "lives", user.neo_id, loc_node_id)
          
        end
        
        likes = user.client.get_connections("me", "likes")

        if likes
          # Import likes
          commands = []
          likes.each do |thing|
            commands << [:create_unique_node, "thing_index", "uid", thing["id"], {"uid" => thing["id"], "name" => thing["name"] }]
          end
          batch_result = $neo_server.batch *commands

          # Add things to an index
          commands = []
          batch_result.each do |b|
            commands << [:add_node_to_index, "things", "name",  b["body"]["data"]["name"], b["body"]["self"].split("/").last]
          end
          $neo_server.batch *commands

          # Connect the user to these things
          commands = []
          batch_result.each do |b|
            commands << [:create_unique_relationship, "likes_index", "user_thing",  "#{uid}-#{b["body"]["data"]["uid"]}", "likes", user.neo_id, b["body"]["self"].split("/").last]
          end
          $neo_server.batch *commands
        end

        # Import Friends
        friends = user.client.get_connections("me", "friends")
        friends.each do |friend|
          Sidekiq::Client.enqueue(Job::ImportFriends, uid, friend["id"])
         # Turning this off breaks viz, so turning it back on.
          Job::ImportMutualFriends.perform_at(30, uid, friend["id"])
        end
      end
    end
  end
end