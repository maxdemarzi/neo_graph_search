# encoding: utf-8
require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe "NGS::Parser" do

  describe "basics" do
      it "can return me" do
        cypher = "START me = node:people(uid:{me}) RETURN me"
        params = {"me" => @neo_id}
        NGS::Parser.parse("(me)").should == [cypher, params]
      end

      it "can return my friends" do
        cypher = "START me = node:people(uid:{me}) MATCH me -[:friends]-> friends RETURN friends"
        params = {"me" => @neo_id}
        NGS::Parser.parse("(friends)").should == [cypher, params]
      end

      it "can return friends who like cheese" do
        cypher = "START me = node:people(uid:{me}), thing = node:things(name:{thing}) MATCH me -[:friends]-> friends, friends -[:likes]-> thing RETURN friends"
        params = {"me" => @neo_id, "thing" => "cheese"}
        NGS::Parser.parse("(friends who like cheese)").should == [cypher, params]
      end

      it "can return friends who like cheese and crackers" do
        cypher = "START me = node:people(uid:{me}), thing1 = node:things(name:{thing1}), thing2 = node:things(name:{thing2}) MATCH me -[:friends]-> friends, friends -[:likes]-> thing1, friends -[:likes]-> thing2 RETURN friends"
        params = {"me" => @neo_id, "thing1" => "cheese", "thing2" => "crackers"}
        NGS::Parser.parse("(friends who like cheese and crackers)").should == [cypher, params]
      end

      it "can return people who like cheese" do
        cypher = "START thing = node:things(name:{thing}) MATCH friends -[:likes]-> thing RETURN friends"
        params = {"thing" => "cheese"}
        NGS::Parser.parse("(people who like cheese)").should == [cypher, params]
      end

      it "can return people who like cheese and crackers" do
        cypher = "START thing1 = node:things(name:{thing1}), thing2 = node:things(name:{thing2}) MATCH friends -[:likes]-> thing1, friends -[:likes]-> thing2 RETURN friends"
        params = {"thing1" => "cheese", "thing2" => "crackers"}
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