require 'spec_helper'

describe OffendingSitesController do

  describe "GET 'index'" do
    it "should be successful" do
      get :index

      response.should be_success
      response.should render_template "index"
      assigns(:offending_sites).should_not be_nil
    end

    it "should show only the first page by default" do
      # First create 25 items
      @list = FactoryGirl.create_list(:OffendingSite, 25, :is_published => true)

      # Now set the per_page attribute to 10
      OffendingSite.per_page = 10

      # Act!
      get :index
      assigns(:offending_sites).length.should eql 10
    end
  end

  describe "GET 'show'" do
    it "should be successful" do
      # Make sure there is an entity in the DB with ID = 1
      orig_site = OffendingSite.where(:id => 1).first
      if orig_site.nil?
        orig_site = FactoryGirl.build(:OffendingSite)
        orig_site.id = 1
      end
      orig_site.url = "http://www.#{Time.now.nsec}.com"
      orig_site.save!

      get :show, :id => 1

      response.should be_success
      response.should render_template "show"
      assigns(:offending_site).should_not be_nil
    end

    it "should redirect to index when ID cannot be found in the DB" do
      get :show, :id => -1

      response.should redirect_to root_url
    end

    it "should redirect to index when ID is invalid" do
      get :show, :id => "hello"

      response.should redirect_to root_url
    end

    it "should redirect to index when ID is of an unpublished entry" do
      # Create the unpublished entry
      orig_site = OffendingSite.where(:id => 1).first
      if orig_site.nil?
        orig_site = FactoryGirl.build(:OffendingSite)
        orig_site.id = 1
      end
      orig_site.is_published = false
      orig_site.save!

      # Act
      get :show, :id => 1

      response.should redirect_to root_url
    end
  end

  describe "GET 'show_by_url'" do
    it "should be successful (with www)" do
      validate_success_by_url "www.google.com"
    end

    it "should be successful (without www)" do
      validate_success_by_url "google.com"
    end

    def validate_success_by_url(url)
      # Make sure there is an entity in the DB with URL = "http://google.com"
      orig_site = OffendingSite.find_by_url("http://google.com")
      if orig_site.nil?
        orig_site = FactoryGirl.build(:OffendingSite)
        orig_site.url = "http://google.com"
      end
      orig_site.save!

      get :show_by_url, :url => url, :id => 1

      response.should be_success
      response.should render_template "show"
      assigns(:offending_site).should_not be_nil
    end

    it "should redirect to index when URL cannot be found in the DB" do
      get :show_by_url, :url => "djsfhdksfhdskjfhdskfshf.mom", :id => 1

      response.should redirect_to root_url
    end

    it "should redirect to index when URL is of an unpublished entry" do
      # Create the unpublished entry
      orig_site = OffendingSite.find_by_url("http://google.com")
      if orig_site.nil?
        orig_site = FactoryGirl.build(:OffendingSite)
        orig_site.url = "http://google.com"
      end
      orig_site.is_published = false
      orig_site.save!

      # Act
      get :show_by_url, :url => "google.com", :id => 1

      response.should redirect_to root_url
    end
  end

  describe "GET 'new'" do
    it "exists" do
      get :new
      response.should render_template "new"
    end
  end

  describe "POST 'create'" do
    it "works when valid data is passed" do
      url = "http://#{Time.now.nsec}.com"
      description = "Hello <b>World</b>"
      name = "Ninja Turtle"
      email = "michaelangelo@ninjaturtules.com"

      post :create, :offending_site => {
          url: url,
          description: description,
          :name => name,
          :email => email,
          :screenshot => fixture_file_upload(File.dirname(__FILE__) + "/../shamrock.jpg", 'image/jpeg', :binary)
      }

      response.should redirect_to root_url
      flash[:notice].should_not be_nil

      # Check that the DB really contains the new record
      newly_created_site = OffendingSite.where(:url => url).first
      newly_created_site.should_not be_nil
      newly_created_site.url        .should eql url
      newly_created_site.description.should eql description
      newly_created_site.name       .should eql name
      newly_created_site.email      .should eql email
    end
    it "returns validation errors when the data is invalid" do
      url = "THIS IS NOT A VALID URL"
      description = ""
      name = ""
      email = "INVALID EMAIL"

      post :create, :offending_site => {
          url: url,
          description: description,
          :name => name,
          :email => email
      }

      response.should render_template "new"
      assigns(:offending_site).should_not be_nil

      # Check that nothing was somehow inserted to the DB
      newly_created_site = OffendingSite.where(:url => url).first
      newly_created_site.should be_nil # If this is not nil, we're screwed!
    end
  end

  describe "GET 'feed'" do
    it "should be successful" do
      get :feed, :format => 'atom'

      response.should be_success
      assigns(:offending_sites).should_not be_nil
    end
  end

  describe "GET 'search'" do
    it "returns correct search results" do
      q = Time.now.nsec.to_s

      # Arrange
      prepare_db q

      # Act
      get :search, :q => q

      # Assert
      offending_sites = assigns(:offending_sites)
      offending_sites.should_not be_nil
      offending_sites.size.should eql 2
      offending_sites[0].id.should_not eql "http://www.gogogogole.com"
      offending_sites[1].id.should_not eql "http://www.gogogogole.com"
    end

    it "doesn't return unpublished posts" do
      q = Time.now.nsec.to_s

      # Arrange
      prepare_db q
      site = OffendingSite.where(:id => 2).first
      site.is_published = false
      site.save!

      # Act
      get :search, :q => q

      # Assert
      offending_sites = assigns(:offending_sites)
      offending_sites.should_not be_nil
      offending_sites.size.should eql 1
    end

    it "returns all when search string is empty" do
      prepare_db Time.now.nsec

      get :search

      # Assert
      offending_sites = assigns(:offending_sites)
      offending_sites.should_not be_nil
      offending_sites.size.should eql OffendingSite.all_published_ordered.count
    end

    it "has paging capabilities" do
      prepare_db Time.now.nsec

      orig_value = OffendingSite.per_page
      OffendingSite.per_page = 1

      get :search

      OffendingSite.per_page = orig_value

      offending_sites = assigns(:offending_sites)
      offending_sites.should_not be_nil
      offending_sites.size.should eql 1
    end


  end

  describe "GET 'check_url'" do
    it "returns true for url not in the DB (with www)" do
      returns_true_test "http://www.mookie.com"
    end

    it "returns true for url not in the DB (without www)" do
      returns_true_test "http://mookie.com"
    end

    it "returns true for url not in the DB (without http://, with www)" do
      returns_true_test "www.mookie.com"
    end

    it "returns true for url not in the DB (without http://, without www)" do
      returns_true_test "mookie.com"
    end

    it "returns false for url in the DB (with www)" do
      returns_false_test "http://www.mookie.com"
    end

    it "returns false for url in the DB (without www)" do
      returns_false_test "http://mookie.com"
    end

    it "returns false for url in the DB (without http://, with www)" do
      returns_false_test "www.mookie.com"
    end

    it "returns false for url in the DB (without http://, without www)" do
      returns_false_test "mookie.com"
    end

    def returns_true_test(url)
      q = Time.now.nsec.to_s

      # Arrange
      prepare_db q

      # Act
      get :check_url, :offending_site => { :url => url }, :format => :json

      # Assert
      @response.body.should eql "true"
    end

    def returns_false_test(url)
      q = Time.now.nsec.to_s

      # Arrange
      prepare_db q
      site = OffendingSite.find(2)
      site.url = "http://mookie.com"
      site.save!

      # Act
      get :check_url, :offending_site => { :url => url }, :format => :json

      # Assert
      @response.body.should eql "false"
    end

    it "responses to JSON only" do
      prepare_db Time.now.nsec.to_s

      # Positive: First check it responses to JSON requests
      get :check_url,  :offending_site => { :url => "http://google.com" }, :format => :json

      @response.body.strip.should_not be_empty

      # Negative: Now check that non-JSON requests get an empty result
      get :check_url,  :offending_site => { :url => "http://google.com" }, :format => :html

      @response.body.strip.should be_empty
    end
  end

  describe "route generation" do
    it "should route /feed" do
      { :get => "/feed" }.should route_to(:controller =>  "offending_sites", :action => "feed", :format => "atom")
    end
    it "should route /rss to feed" do
      { :get => "/rss" }.should route_to(:controller =>  "offending_sites", :action => "feed", :format => "atom")
    end
    it "should route /search" do
      { :get => "/search" }.should route_to(:controller =>  "offending_sites", :action => "search")
    end
    it "should route /terms" do
      { :get => "/terms" }.should route_to(:controller =>  "offending_sites", :action => "terms")
    end
    it "should route /check_site_url to check_url" do
      { :get => "/check_site_url" }.should route_to(:controller =>  "offending_sites", :action => "check_url")
    end
    it "should route /create-new to new" do
      { :get => "/create-new" }.should route_to(:controller =>  "offending_sites", :action => "new")
    end
    it "should route site/:url to show_by_url with correct url" do
      { :get => "/site/google.com" }.should route_to(:controller =>  "offending_sites", :action => "show_by_url", :url => "google.com")
    end
  end

  # *************** Helper methods ******************

  def prepare_db(q)
      add_to_db(1, "http://www.#{q}.com")
      add_to_db(2, "http://www.#{q}11.com")
      add_to_db(3, "http://www.gogogogole.com")
    end

  def add_to_db(id, url, is_published=true)
    orig_site = OffendingSite.where(:id => id).first
    if orig_site.nil?
      orig_site = FactoryGirl.build(:OffendingSite)
      orig_site.id = id
    end
    orig_site.url = url
    orig_site.is_published = is_published
    orig_site.save!
  end
end
