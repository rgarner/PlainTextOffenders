require 'spec_helper'

describe OffendingSite do
  describe "url" do
    it "is present" do
      error_message = "can't be blank"

      site = OffendingSite.new :url => 'http://www.google.com'
      site.valid?
      site.errors[:url].should_not include(error_message)

      site.url = nil
      site.should_not be_valid
      site.errors[:url].should include(error_message)

      site.url = ''
      site.should_not be_valid
      site.errors[:url].should include(error_message)
    end

    it "is valid url" do
      error_message = "is invalid"

      site = OffendingSite.new :url => 'http://www.google.com'
      site.valid?
      site.errors[:url].should_not include(error_message)

      site.url = 'oy vey zmir!'
      site.should_not be_valid
      site.errors[:url].should include(error_message)
    end

    it "is unique" do
      site = FactoryGirl.build(:OffendingSite)
      site.url = "http://www.google.com"
      site.should be_valid
      site.save!

      site = FactoryGirl.build(:OffendingSite)
      site.url = "http://www.google.com"
      site.should_not be_valid
    end
  end

  describe "description" do
    it "is optional" do
      site = FactoryGirl.build(:OffendingSite)
      site.description = 'yo yo yo'
      site.should be_valid

      site.description = ''
      site.should be_valid
    end

    it "allows only b, i and u HTML elements inside" do
      site = FactoryGirl.build(:OffendingSite)
      # Positive test
      site.description = "This is <b>bold</b> and <i>italic</i> and <u>underline</u>"
      site.description.should eql "This is <b>bold</b> and <i>italic</i> and <u>underline</u>"

      # Negative test
      site.description = "This is <b>bold</b> and <i>italic</i> and <u>underline</u> <script>alert('Mookie');</script>"
      site.description.should eql "This is <b>bold</b> and <i>italic</i> and <u>underline</u> &lt;script&gt;alert('Mookie');&lt;/script&gt;"
    end
  end

  describe "name" do
    it "is required" do
      site = FactoryGirl.build(:OffendingSite)
      site.name = 'yo yo yo'
      site.should be_valid

      site.name = ''
      site.should_not be_valid
    end
  end

  describe "email" do
    it "is required" do
      site = FactoryGirl.build(:OffendingSite)
      site.email = 'google@google.com'
      site.should be_valid

      site.email = ''
      site.should_not be_valid
    end

    it "allows only valid values" do
      site = Factory(:OffendingSite)
      site.email = 'google@google.com'
      site.should be_valid

      site.email = 'google'
      site.should_not be_valid
      site.errors[:email].should include('is invalid')

      site.email = 'goo@goo.'
      site.should_not be_valid
      site.errors[:email].should include('is invalid')
    end
  end

  describe "is_published" do
    it "defaults to false" do
      site = OffendingSite.new :is_published => true
      site.is_published.should be_true

      site = OffendingSite.new
      site.is_published.should be_false
    end
  end

  describe "published_at" do
    it "defaults to null" do
      site = OffendingSite.new :published_at => DateTime.new
      site.published_at.should_not be_nil

      site = OffendingSite.new
      site.published_at.should be_nil
    end
    it "is null when site is not published" do
      site = OffendingSite.new
      site.is_published = false

      site.published_at.should be_nil
    end
    it "contains a datetime when site is published" do
      site = OffendingSite.new
      site.is_published = true

      site.published_at.should_not be_nil
      site.published_at.should satisfy do |d|
        from = 10.seconds.ago
        to = Time.now

        d >= from and d <= to
      end
    end
  end

  describe "screenshot" do
    it { should have_attached_file(:screenshot) }
    it { should validate_attachment_presence(:screenshot) }
  end

  describe "terms_of_service" do
    it 'must be accepted' do
      site = FactoryGirl.build(:OffendingSite)
      site.terms_of_service = '1'
      site.should be_valid

      site.terms_of_service = '0'
      site.should_not be_valid
    end
  end

  describe "short_url" do
    it "should return url without http:// and without www" do
      site = FactoryGirl.build(:OffendingSite)

      site.url = "http://www.google.com"
      site.short_url.should eql "google.com"

      site.url = "http://google.com"
      site.short_url.should eql "google.com"

      site.url = "www.google.com"
      site.short_url.should eql "google.com"

      site.url = "google.com"
      site.short_url.should eql "google.com"

      site.url = "http://sub.google.com"
      site.short_url.should eql "sub.google.com"
    end

    it "should be ok with empty urls" do
      site = FactoryGirl.build(:OffendingSite)

      site.url = ""
      site.short_url.should eql ""
    end

    it "should be ok with nil urls" do
      site = FactoryGirl.build(:OffendingSite)

      site.url = nil
      site.short_url.should eql nil
    end

  end

  describe "all_ordered" do
    # Clear DB
    OffendingSite.all.each { |x| x.delete }

    sites = FactoryGirl.build_list(:OffendingSite, 2)
    sites[0].created_at = 10.days.ago
    sites[1].created_at = 5.seconds.ago
    sites[0].save!
    sites[1].save!

    results = OffendingSite.all_ordered

    results.size.should == 2
    results[0].should == sites[1]
    results[1].should == sites[0]
  end

  describe "all_published_ordered" do
    # Clear DB
    OffendingSite.all.each { |x| x.delete }

    sites = FactoryGirl.build_list(:OffendingSite, 3)
    sites[0].is_published = true
    sites[1].is_published = false
    sites[2].is_published = true
    sites[0].published_at = 10.days.ago
    sites[2].published_at = 5.seconds.ago
    0.upto(2).each {|i| sites[i].save! }

    results = OffendingSite.all_published_ordered

    results.size.should == 2
    results[0].should == sites[2]
    results[1].should == sites[0]
  end

  describe "search" do
    it "should return search results according to search string" do
      prepare_db_for_search

      results = OffendingSite.search("foo")

      results.should_not be_nil
      results.size.should eql 1
      results[0].url.should eql "http://foo.com"
    end

    it "should return all published results when search string is blank" do
      prepare_db_for_search

      results = OffendingSite.search nil

      results.should_not be_nil
      results.size.should eql 2 # One site is unpublished so it shouldn't be here
    end

    it "should return results ordered by publish date" do
      prepare_db_for_search

      results = OffendingSite.search ""

      results.should_not be_nil
      results[0].url.should eql "http://bar.com"
      results[1].url.should eql "http://foo.com"
    end

    def prepare_db_for_search
      # Clear DB
      OffendingSite.all.each { |x| x.delete }
      # Arrange DB
      sites = FactoryGirl.build_list(:OffendingSite, 3)
      sites[0].is_published = true
      sites[1].is_published = false
      sites[2].is_published = true
      sites[0].published_at = 10.days.ago
      sites[2].published_at = 5.seconds.ago
      sites[0].url = "http://foo.com"
      sites[2].url = "http://bar.com"
      0.upto(2).each {|i| sites[i].save! }
    end
  end
end
