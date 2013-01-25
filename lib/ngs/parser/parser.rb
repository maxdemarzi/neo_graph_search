module NGS
  class Parser
   
     Treetop.load(File.expand_path(File.join(File.dirname(__FILE__), 'ngs_parser.treetop')))
     @@parser = NgsParser.new
   
     # Parse an input string and return a Ruby array like:
     #   [:this, :is, [:a, :test]]
     def self.parse(data)

       # Pass the data over to the parser instance
       tree = @@parser.parse(data)

       # If the AST is nil then there was an error during parsing
       # we need to report a simple error message to help the user
       if(tree.nil?)
         raise Exception, "Parse error at offset: #{@@parser.index}"
       end

       # Remove all syntax nodes that aren't one of our custom
       # classes. If we don't do this we will end up with a *lot*
       # of essentially useless nodes
       self.clean_tree(tree)

       # Convert the AST into an array representation of the input
       # structure and return it
       return tree.to_cypher
     end

     private

       def self.clean_tree(root_node)
         return if(root_node.elements.nil?)
         root_node.elements.delete_if{|node| node.class.name == "Treetop::Runtime::SyntaxNode" }
         root_node.elements.each {|node| self.clean_tree(node) }
       end   
   
   end
end