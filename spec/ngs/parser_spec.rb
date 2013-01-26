# encoding: utf-8
require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe "NGS::Parser" do

  describe "basics" do
      it "can return me" do
        cypher = "START me = node({me}) RETURN DISTINCT me"
        params = {"me" => nil}
        NGS::Parser.parse("(me)").should == [cypher, params]
      end

      it "can return my friends" do
        cypher = "START me = node({me}) MATCH me -[:friends]-> people RETURN DISTINCT people"
        params = {"me" => nil}
        NGS::Parser.parse("(friends)").should == [cypher, params]
      end

      it "can return friends who like cheese" do
        cypher = "START me = node({me}), thing = node:things({thing}) MATCH me -[:friends]-> people, people -[:likes]-> thing RETURN DISTINCT people"
        params = {"me" => nil, "thing" => "name: cheese"}
        NGS::Parser.parse("(friends who like cheese)").should == [cypher, params]
      end

      it "can return friends who like cheese and crackers" do
        cypher = "START me = node({me}), thing1 = node:things({thing1}), thing2 = node:things({thing2}) MATCH me -[:friends]-> people, people -[:likes]-> thing1, people -[:likes]-> thing2 RETURN DISTINCT people"
        params = {"me" => nil, "thing1" => "name: cheese", "thing2" => "name: crackers"}
        NGS::Parser.parse("(friends who like cheese and crackers)").should == [cypher, params]
      end

      it "can return people who like cheese" do
        cypher = "START thing = node:things({thing}) MATCH people -[:likes]-> thing RETURN DISTINCT people"
        params = {"thing" => "name: cheese"}
        NGS::Parser.parse("(people who like cheese)").should == [cypher, params]
      end

      it "can return people who like cheese and crackers" do
        cypher = "START thing1 = node:things({thing1}), thing2 = node:things({thing2}) MATCH people -[:likes]-> thing1, people -[:likes]-> thing2 RETURN DISTINCT people"
        params = {"thing1" => "name: cheese", "thing2" => "name: crackers"}
        NGS::Parser.parse("(people who like cheese and crackers)").should == [cypher, params]
      end

      it "can return people who like cyling and live in Florida" do
        cypher = "START thing = node:things({thing}), place = node:places({place}) MATCH people -[:likes]-> thing1, people -[:lives]-> place RETURN DISTINCT people"
        params = {"thing" => "name: cheese", "place" => "name: Florida"}
        NGS::Parser.parse("(people who like cheese and live in Florida)").should == [cypher, params]
      end

# People who like Cycling 
# People who like Cycling and are from my hometown
# People who like Cycling and live in Seattle, Washington
# Photos I like
# Photos before 1990
# Photos of my friends in New York
# Music my friends like
# Cities my family visited
# Restaurants in London my friends have been to


  end
end