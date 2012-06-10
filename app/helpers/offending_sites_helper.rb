module OffendingSitesHelper
  def post_date_format(date)
    date.strftime("%B #{date.day.ordinalize}, %Y at %l:%M%p")
  end
end
