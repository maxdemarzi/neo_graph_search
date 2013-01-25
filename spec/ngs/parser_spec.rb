# encoding: utf-8
require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe "NGS::Parser" do

  describe "basics" do
      it "can return return me" do
        NGS::Parser.parse("(me)").should == "START me = node:people(uid:{me}) RETURN me"
      end

      it "can return return my friends" do
        NGS::Parser.parse("(friends)").should == "MATCH me -[:friends]-> friends"
      end

      it "can return return likes" do
        NGS::Parser.parse("(who like)").should == "-[:likes]->"
      end

      it "can return return friends who like" do
        NGS::Parser.parse("(friends who like)").should == "MATCH me -[:friends]-> friends -[:likes]->"
      end

      it "can return return friends who like cheese" do
        NGS::Parser.parse("(friends who like cheese)").should == "MATCH me -[:friends]-> friends -[:likes]-> this"
      end


  end
end