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
        cypher = "START me = node({me}) MATCH me -[:friends]-> friends RETURN DISTINCT friends"
        params = {"me" => nil}
        NGS::Parser.parse("(friends)").should == [cypher, params]
      end

      it "can return friends who like cheese" do
        cypher = "START me = node({me}), thing = node:things({thing}) MATCH me -[:friends]-> friends, friends -[:likes]-> thing RETURN DISTINCT friends"
        params = {"me" => nil, "thing" => "name: cheese"}
        NGS::Parser.parse("(friends who like cheese)").should == [cypher, params]
      end

      it "can return friends who like cheese and crackers" do
        cypher = "START me = node({me}), thing1 = node:things({thing1}), thing2 = node:things({thing2}) MATCH me -[:friends]-> friends, friends -[:likes]-> thing1, friends -[:likes]-> thing2 RETURN DISTINCT friends"
        params = {"me" => nil, "thing1" => "name: cheese", "thing2" => "name: crackers"}
        NGS::Parser.parse("(friends who like cheese and crackers)").should == [cypher, params]
      end

      it "can return people who like cheese" do
        cypher = "START thing = node:things({thing}) MATCH friends -[:likes]-> thing RETURN DISTINCT friends"
        params = {"thing" => "name: cheese"}
        NGS::Parser.parse("(people who like cheese)").should == [cypher, params]
      end

      it "can return people who like cheese and crackers" do
        cypher = "START thing1 = node:things({thing1}), thing2 = node:things({thing2}) MATCH friends -[:likes]-> thing1, friends -[:likes]-> thing2 RETURN DISTINCT friends"
        params = {"thing1" => "name: cheese", "thing2" => "name: crackers"}
        NGS::Parser.parse("(people who like cheese and crackers)").should == [cypher, params]
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