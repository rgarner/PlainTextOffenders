class OffendingSite < ActiveRecord::Base
  self.per_page = 10

  has_attached_file :screenshot

  validates :url, :presence => true, :uniqueness => true, :format => { :with => /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix }
  validates :email, :format => {:with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i}, :allow_blank => false
  validates :name, :presence => true
  validates_attachment_presence :screenshot
  validates :screenshot, :presence => true # needed for client_side_validations
  validates :terms_of_service, :acceptance => true # this does not have a column in the DB (no need to). It is here for validation reasons only.

  def short_url
    return nil if url.nil?
    url.gsub("http://","").gsub("www.", "")
  end

  def is_published=(val)
    write_attribute :is_published, val

    # set updated_at
    self.published_at = val ? Time.now : nil
  end

  def description=(val)
    # converting newlines
    val.gsub!(/\r\n?/, "\n")

    # escaping HTML to entities
    val = val.to_s.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')

    # Allow b, i and u
    %w(b i u).each { |x|
         val.gsub!(Regexp.new('&lt;(' + x + ')&gt;(.+?)&lt;/('+x+')&gt;',
                 Regexp::MULTILINE|Regexp::IGNORECASE),
                 "<\\1>\\2</\\1>")
        }

    # replacing newlines to <br> and <p> tags
    # wrapping text into paragraph
    val = val.gsub(/\n\n+/, "</p>\n\n<p>").
            gsub(/([^\n]\n)(?=[^\n])/, '\1<br />')

    write_attribute :description, val
  end

  # Static methods

  def OffendingSite.all_ordered
    OffendingSite.order("created_at DESC")
  end

  def OffendingSite.all_published_ordered
    OffendingSite.where(:is_published => true).order("published_at DESC")
  end

  def OffendingSite.search(search_string)
    OffendingSite.where("url like ?", "%#{search_string}%").where(:is_published => true).order("published_at DESC")
  end
end
