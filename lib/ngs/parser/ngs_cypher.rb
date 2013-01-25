module Ngs
  
  class Expression < Treetop::Runtime::SyntaxNode
    def to_cypher
      return self.elements[0].to_cypher
    end
  end
  
  class Body < Treetop::Runtime::SyntaxNode
    def to_cypher
      return self.elements.map {|x| x.to_cypher}.join(" ")
    end
  end
  
  class Me < Treetop::Runtime::SyntaxNode
    def to_cypher
        return "me = node:people(uid:{me})"
    end 
  end

  class Friends < Treetop::Runtime::SyntaxNode
    def to_cypher
        return "MATCH me -[:friends]-> friends"
    end 
  end

  class Likes < Treetop::Runtime::SyntaxNode
    def to_cypher
        return "-[:likes]->"
    end 
  end

  
end