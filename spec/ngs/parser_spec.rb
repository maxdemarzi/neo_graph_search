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
        cypher = "START me = node:people(uid:{me}), thing = node:things(name:{thing}) MATCH me -[:friends]-> friends -[:likes]-> thing RETURN friends"
        params = {"me" => @neo_id, "thing" => "cheese"}
        NGS::Parser.parse("(friends who like cheese)").should == [cypher, params]
      end

  end
end