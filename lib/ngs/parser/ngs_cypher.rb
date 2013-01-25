module Ngs
  
  class Expression < Treetop::Runtime::SyntaxNode
    def to_cypher
      cypher_hash =  self.elements[0].to_cypher
      cypher_string = ""
      cypher_string << "START "   + cypher_hash[:start].join(", ")
      cypher_string << " MATCH "  + cypher_hash[:match].join(" ") unless cypher_hash[:match].empty?
      cypher_string << " RETURN " + cypher_hash[:return].join(", ")
      params = cypher_hash[:params].empty? ? nil : cypher_hash[:params].inject {|a,h| a.merge(h)}
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
        return {:start => "me = node:people(uid:{me})", 
                :return => "me",
                :params => {"me" => @neoid}}
    end 
  end

  class Friends < Treetop::Runtime::SyntaxNode
    def to_cypher
        return {:start  => "me = node:people(uid:{me})", 
                :match  => "me -[:friends]-> friends",
                :return => "friends",
                :params => {"me" => @neoid}}
    end 
  end

  class Likes < Treetop::Runtime::SyntaxNode
    def to_cypher
        return {:match => "-[:likes]-> thing"}
    end 
  end

  class Thing < Treetop::Runtime::SyntaxNode
    def to_cypher
        return {:start => "thing = node:things(name:{thing})",
                :params => {"thing" => self.text_value} }
    end 
  end

  
end