require 'spec_helper'


describe Admin::OffendingSitesController do
  before :each do
    @controller = Admin::OffendingSitesController.new
    # pass authorization:
    @request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64("admin:hello")
  end

  describe "authorization" do
    it "requests basic authentication to view page" do
      name = "admin"
      password = "hello"

      @request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64("#{name}:#{password}")
      get :index

      response.status.should eql 200
      response.status.should_not eql 401
    end

    it "prohibits unauthenticated users to view admin pages" do
      name = "foo"
      password = "bar"

      @request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64("#{name}:#{password}")
      get :index

      response.status.should eql 401
      response.status.should_not eql 200
    end
  end

  describe "index" do
    it "should response successfully with :offending_sites assigned" do
      @list = FactoryGirl.create_list(:OffendingSite, 25)

      get :index

      response.status.should eql 200
      assigns(:offending_sites).should_not be_nil
    end
  end
  describe "new" do
    it "exists" do
      get :new

      response.status.should eql 200
      assigns(:offending_site).should_not be_nil
    end
  end

  describe "create" do
    it "adds a new record" do
      item_count = OffendingSite.count

      post :create, :offending_site => {
          :url =>  'http://www.tamtamtam.com',
          :description => 'Tam tam tam',
          :name => 'John Doe',
          :email => 'john@doe.com',
          :is_published => '0',
          :screenshot => fixture_file_upload(File.dirname(__FILE__) + "/../../shamrock.jpg", 'image/jpeg', :binary)
      }

      response.should redirect_to admin_offending_sites_url
      OffendingSite.count.should eql item_count+1


      # This was a try to use capybara but it failed because of the basic authentication. Dropping it for now

      # visit '/admin/offending_sites/new'
      #
      # fill_in 'Url', :with => 'http://www.tamtamtam.com'
      # fill_in 'Description', :with => 'Tam tam tam'
      # fill_in 'Creator name', :with => 'John Doe'
      # fill_in 'Creator email', :with => 'john@doe.com'
      # attach_file 'Screenshot',  File.dirname(__FILE__) + "/../../shamrock.jpg"
      # click_button 'Create offending site'
    end

    it "renders the same template when there are validation errors + nothing is added to the DB" do
      item_count = OffendingSite.count

      post :create, :offending_site => {
          :url =>  '', # This should create a validation error
          :description => 'Tam tam tam',
          :name => 'John Doe',
          :email => 'john@doe.com',
          :is_published => '0',
          :screenshot => fixture_file_upload(File.dirname(__FILE__) + "/../../shamrock.jpg", 'image/jpeg', :binary)
      }

      response.should render_template "new"
      OffendingSite.count.should eql item_count
    end
  end

  describe "edit" do
    it "exists" do
      site = OffendingSite.where(:id => 1).first
      if site.nil?
        site = FactoryGirl.build(:OffendingSite)
        site.id = 1
      end
      site.url = "http://www.#{Time.now.nsec}.com"
      site.save!


      get :edit, :id => 1

      response.status.should eql 200
      assigns(:offending_site).should_not be_nil
      assigns(:offending_site).id.should eql site.id
      assigns(:offending_site).url.should eql site.url
    end
    it "redirects to list with a flash notice if ID is not present" do
      get :edit, :id => -1

      response.should redirect_to admin_offending_sites_url
      flash[:error].should_not be_nil
    end

  end

  describe "update" do
    it "updates the correct record with the correct data" do
      orig_site = OffendingSite.where(:id => 1).first
      if orig_site.nil?
        orig_site = FactoryGirl.build(:OffendingSite)
        orig_site.id = 1
      end
      orig_site.url = "http://www.#{Time.now.nsec}.com"
      orig_site.save!

      new_description = "This is a new description #{Time.now}"
      new_name = "New name! #{Time.now}"
      new_is_published = !orig_site.is_published
      new_url = "http://www.#{Time.now.nsec}1.com"
      new_email = "aa#{Time.now.nsec}@moo.com"

      put :update, :id=>1, :offending_site => {
          :id => 1,
          :url =>  new_url,
          :description => "#{new_description}",
          :name => new_name,
          :email => new_email,
          :is_published => new_is_published.to_s,
          :screenshot => fixture_file_upload(File.dirname(__FILE__) + "/../../shamrock.jpg", 'image/jpeg', :binary)
      }

      # Get the updated item from the DB
      updated_item = OffendingSite.find(1)

      response.should redirect_to admin_offending_sites_url
      flash[:notice].should_not be_nil

      updated_item.url          .should eql new_url
      updated_item.description  .should eql new_description
      updated_item.name         .should eql new_name
      updated_item.email        .should eql new_email
      updated_item.is_published .should eql new_is_published
    end

    it "returns to the same template when there are validation errors + DB isn't changed" do
      orig_site = OffendingSite.where(:id => 1).first
      if orig_site.nil?
        orig_site = FactoryGirl.build(:OffendingSite)
        orig_site.id = 1
      end
      orig_site.url = "http://www.#{Time.now.nsec}.com"
      orig_site.save!

      put :update, :id=>1, :offending_site => {
          :id => 1,
          :url =>  "http://www.google.com",
          :description => "",
          :name => "",
          :email => "invalid email!",
          :is_published => '0'
      }

      response.should render_template "edit"
      # Make sure nothing has been changed in the DB
      updated_item = OffendingSite.find(1)
      updated_item.url          .should eql orig_site.url
      updated_item.description  .should eql orig_site.description
      updated_item.name         .should eql orig_site.name
      updated_item.email        .should eql orig_site.email
      updated_item.is_published .should eql orig_site.is_published
    end

    it "redirects to list with a flash notice if ID is not present" do
      put :update, :id => -1

      response.should redirect_to admin_offending_sites_url
      flash[:error].should_not be_nil
    end
  end

  describe "destroy" do
    it "deletes the record and redirects to list with a flash notice" do
      orig_site = OffendingSite.where(:id => 1).first
      if orig_site.nil?
        orig_site = FactoryGirl.build(:OffendingSite)
        orig_site.id = 1
      end
      orig_site.save!

      delete :destroy, :id=>1

      response.should redirect_to admin_offending_sites_url
      flash[:notice].should_not be_nil

      # Make sure the item is not in the DB anymore
      orig_site_count = OffendingSite.where(:id => 1).count
      orig_site_count.should eql 0
    end
    it "redirects to list with a flash notice if ID is not present" do
      delete :destroy, :id=> -1

      response.should redirect_to admin_offending_sites_url
      flash[:error].should_not be_nil
    end
  end

  describe "publish" do
    it "updates the record to a published status" do
      orig_site = OffendingSite.where(:id => 1).first
      if orig_site.nil?
        orig_site = FactoryGirl.build(:OffendingSite)
        orig_site.id = 1
      end
      orig_site.is_published = false
      orig_site.save!

      get :publish, :id => 1

      response.should redirect_to admin_offending_sites_url
      flash[:notice].should_not be_nil

      # Make sure the DB has been changed
      updated_item = OffendingSite.find(1)
      updated_item.is_published.should be_true
    end

    it "redirects to list with a flash notice if ID is not present"  do
      get :publish, :id=> -1

      response.should redirect_to admin_offending_sites_url
      flash[:error].should_not be_nil
    end
  end

  describe "unpublish" do
    it "updates the record to an unpublished status" do
      orig_site = OffendingSite.where(:id => 1).first
      if orig_site.nil?
        orig_site = FactoryGirl.build(:OffendingSite)
        orig_site.id = 1
      end
      orig_site.is_published = false
      orig_site.save!

      get :unpublish, :id => 1

      response.should redirect_to admin_offending_sites_url
      flash[:notice].should_not be_nil

      # Make sure the DB has been changed
      updated_item = OffendingSite.find(1)
      updated_item.is_published.should be_false
    end

    it "redirects to list with a flash notice if ID is not present" do
      get :unpublish, :id=> -1

      response.should redirect_to admin_offending_sites_url
      flash[:error].should_not be_nil
    end
  end

end
