module Ngs
  
  class Expression < Treetop::Runtime::SyntaxNode
    def to_cypher
      cypher_hash =  self.elements[0].to_cypher
      cypher_string = ""
      cypher_string << "START "   + cypher_hash[:start].uniq.join(", ")
      cypher_string << " MATCH "  + cypher_hash[:match].uniq.join(", ") unless cypher_hash[:match].empty?
      cypher_string << " RETURN DISTINCT " + cypher_hash[:return].uniq.join(", ")
      params = cypher_hash[:params].empty? ? {} : cypher_hash[:params].uniq.inject {|a,h| a.merge(h)}
      return [cypher_string, params].compact
    end
  end
  
  class Body < Treetop::Runtime::SyntaxNode
    def to_cypher
      cypher_hash = Hash.new{|h, k| h[k] = []}
      self.elements.each do |x|
        x.to_cypher.each do |k,v|
          cypher_hash[k] << v
        end
      end
      return cypher_hash
    end
  end
  
  class Me < Treetop::Runtime::SyntaxNode
    def to_cypher
        return {:start => "me = node({me})", 
                :return => "me",
                :params => {"me" => nil }}
    end 
  end

  class Friends < Treetop::Runtime::SyntaxNode
    def to_cypher
        return {:start  => "me = node({me})", 
                :match  => "me -[:friends]-> people",
                :return => "people",
                :params => {"me" => nil }}
    end 
  end

  class Likes < Treetop::Runtime::SyntaxNode
    def to_cypher
        return {:match => "people -[:likes]-> thing"}
    end 
  end

  class Lives < Treetop::Runtime::SyntaxNode
    def to_cypher
        return {:start => "place = node:places({place})",
                :match => "people -[:lives]-> place",
                :params => {"place" => "name: " + self.text_value.split("in").last.to_s.strip + "*" } }
    end 
  end

  class LikeAnd < Treetop::Runtime::SyntaxNode
    def to_cypher
        return {:start  => "thing1 = node:things({thing1}), thing2 = node:things({thing2})",
                :match  => "people -[:likes]-> thing1, people -[:likes]-> thing2",
                :params => {"thing1" => "name: " + self.elements[1].text_value, "thing2" => "name: " + self.elements.last.text_value} }
    end 
  end

  class LikeAndLives < Treetop::Runtime::SyntaxNode
    def to_cypher
        return {:start  => "thing = node:things({thing}), place = node:places({place})",
                :match  => "people -[:likes]-> thing, people -[:lives]-> place",
                :params => {"thing" => "name: " + self.elements[1].text_value, "place" => "name: " + self.elements.last.text_value.split("in").last.to_s.strip + "*"} }
    end 
  end

  class Thing < Treetop::Runtime::SyntaxNode
    def to_cypher
        return {:start  => "thing = node:things({thing})",
                :params => {"thing" => "name: " + self.text_value } }
    end 
  end

  class People < Treetop::Runtime::SyntaxNode
    def to_cypher
        return {#:start => "people = node:people(\"name:*\")",
                :return => "people"}
    end 
  end

  
end