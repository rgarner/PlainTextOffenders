include OffendingSitesHelper

describe OffendingSitesHelper do
  it "should return a correctly formatted date" do
    date = Time.new(2011, 9, 6, 15, 30, 20)
    post_date_format(date).should eql "September 6th, 2011 at  3:30PM"
  end
  it "should return 1st, 2nd and 3rd on such days" do
    date = Time.new(2010, 1, 1, 10, 20, 20)
    post_date_format(date).should eql "January 1st, 2010 at 10:20AM"

    date = Time.new(2010, 1, 2, 10, 20, 20)
    post_date_format(date).should eql "January 2nd, 2010 at 10:20AM"

    date = Time.new(2010, 1, 3, 10, 20, 20)
    post_date_format(date).should eql "January 3rd, 2010 at 10:20AM"
  end
end