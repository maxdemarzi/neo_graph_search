module Job
  class ImportFacebookProfile
    include Sidekiq::Worker
    sidekiq_options :retry => false

    def perform(uid)
      user = User.find_by_uid(uid)
      if user
        likes = user.client.get_connections("me", "likes")

        if likes
          # Import likes
          commands = []
          likes.each do |thing|
            commands << [:create_unique_node, "thing_index", "uid", thing["id"], {"uid" => thing["id"], "name" => thing["name"] }]
          end
          batch_result = $neo_server.batch *commands

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
          Job::ImportMutualFriends.perform_at(30, uid, friend["id"])
        end
      end
    end
  end
end