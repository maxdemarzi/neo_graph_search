class User
  attr_reader :neo_id
  attr_accessor :uid, :name, :image_url, :location, :token

  def initialize(node)
    @neo_id     = node["self"].split('/').last.to_i
    @uid        = node["data"]["uid"]
    @name       = node["data"]["name"]
    @image_url  = node["data"]["img_url"]
    @location   = node["data"]["location"]
    @token      = node["data"]["token"]
  end

  def self.find_by_uid(uid)
    user = $neo_server.get_node_index("user_index", "uid", uid)

    if user
      User.new(user.first)
    else
      nil
    end
  end

  def self.create_with_omniauth(auth)
    values = {"name"      => auth.info.name,
              "image_url" => auth.info.image || '/images/icon_no_photo_80x80.png',
              "location"  => auth.info.location || '',
              "uid"       => auth.uid,
              "token"     => auth.credentials.token}
    node = $neo_server.create_unique_node("user_index", "uid", auth.uid)
    if node
      neo_id = node["self"].split('/').last.to_i
      $neo_server.set_node_properties(neo_id, values)
      node = $neo_server.get_node(neo_id)

      Sidekiq::Client.enqueue(Job::ImportFacebookProfile, auth.uid)
      User.new(node)
    else
      nil
    end
  end

  def self.create_from_facebook(friend)
    id        = friend["id"]
    name      = friend["name"]
    location  = friend["location"] ? (friend["location"]["name"] || "") : ""
    image_url = "https://graph.facebook.com/#{friend["id"]}/picture"

    node = $neo_server.create_unique_node("user_index", "uid", id,
                                          {"name"      => name,
                                           "location"  => location,
                                           "image_url" => image_url,
                                           "uid"       => id
                                          })
    User.new(node)
  end

  def client
    @client ||= Koala::Facebook::API.new(self.token)
  end

  def add_like(like_id)
    like = Like.get_by_id(like_id)
    if like
      $neo_server.create_unique_relationship("has_index", "user_value",  "#{@uid}-#{like["data"]["name"]}", "has", @neo_id, Like.neo_id(like))
    end
  end

  def likes
    cypher = "START me = node({id})
              MATCH me -[:likes]-> like
              RETURN ID(like), like.name"
    results = $neo_server.execute_query(cypher, {:id => @neo_id})
    Array(results["data"])
  end

  def likes_count
    cypher = "START me = node({id})
              MATCH me -[:likes]-> like
              RETURN COUNT(like)"
    results = $neo_server.execute_query(cypher, {:id => @neo_id})

    if results["data"][0]
      results["data"][0][0]
    else
      0
    end
  end

  def friends
    cypher = "START me = node({id})
              MATCH me -[:friends]-> friend
              RETURN friend.uid, friend.name, friend.image_url"
    results = $neo_server.execute_query(cypher, {:id => @neo_id})

    Array(results["data"])
  end

  def friends_count
    cypher = "START me = node({id})
              MATCH me -[:friends]-> friend
              RETURN COUNT(friend)"
    results = $neo_server.execute_query(cypher, {:id => @neo_id})

    if results["data"][0]
      results["data"][0][0]
    else
      0
    end

  end

  def friend_matrix
    cypher =  "START me = node({id})
               MATCH me -[:friends]-> friends -[:friends]-> fof
               WHERE fof <> me
               RETURN friends.name, collect(fof.name)
               ORDER BY COUNT(fof) "
    $neo_server.execute_query(cypher, {:id => @neo_id})["data"]
  end

end