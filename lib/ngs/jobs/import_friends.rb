module Job
  class ImportFriends
    include Sidekiq::Worker
    sidekiq_options :retry => false

    def perform(uid, person_id)
      user = User.find_by_uid(uid)
      if user
        person = user.client.get_object(person_id)
        if person
          friend = User.create_from_facebook(person)

          # Make them friends
          commands = []
          commands << [:create_unique_relationship, "friends_index", "ids",  "#{uid}-#{person_id}", "friends", user.neo_id, friend.neo_id]
          commands << [:create_unique_relationship, "friends_index", "ids",  "#{person_id}-#{uid}", "friends", friend.neo_id, user.neo_id]
          batch_result = $neo_server.batch *commands

          # Import friend likes
          likes = user.client.get_connections(person_id, "likes")

          if likes
            # Import things
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
              commands << [:create_unique_relationship, "likes_index", "user_thing",  "#{person_id}-#{b["body"]["data"]["uid"]}", "likes", friend.neo_id, b["body"]["self"].split("/").last]
            end
            $neo_server.batch *commands
          end
        end
      end
    end

  end
end