# encoding: utf-8
require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe "NGS::Parser" do

  describe "basics" do
      it "can return return me" do
        cypher = "START me = node:people(uid:{me}) RETURN me"
        NGS::Parser.parse("(me)").should == cypher
      end

      it "can return return my friends" do
        cypher = "START me = node:people(uid:{me}) MATCH me -[:friends]-> friends RETURN friends"
        NGS::Parser.parse("(friends)").should == cypher
      end

      it "can return return friends who like cheese" do
        cypher = "START me = node:people(uid:{me}), thing = node:things(name:{thing}) MATCH me -[:friends]-> friends -[:likes]-> thing RETURN friends"
        NGS::Parser.parse("(friends who like cheese)").should == cypher
      end

  end
end