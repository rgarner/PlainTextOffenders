require 'spec_helper'

describe PagesController do

  describe "GET 'about_us'" do
    it "should be successful" do
      get 'about_us'
      response.should be_success
      response.should render_template "about_us"
    end
  end

  describe "GET 'talk_to_us'" do
    it "should be successful" do
      get 'talk_to_us'
      response.should be_success
      response.should render_template "talk_to_us"
    end
  end

  describe "route generation" do
    it "should route about-us to about_us" do
      { :get => "/about-us" }.should route_to(:controller =>  "pages", :action => "about_us")
    end
    it "should route talk-to-us to talk_to_us" do
      { :get => "/talk-to-us" }.should route_to(:controller =>  "pages", :action => "talk_to_us")
    end
  end
end
