FactoryGirl.define do
  factory :OffendingSite do
    sequence(:url) { |n| "http://google#{n}.com" }
    description   'This is a good description'
    name         'John Doe'
    email         'google@google.com'
    is_published  true
    published_at  DateTime.new(2012,12,21,12,00)
    screenshot_file_name    'img.png'
    screenshot_content_type 'image/png'
    screenshot_file_size    1024
    screenshot_updated_at    DateTime.new(2012, 12, 21)
    terms_of_service '1'
  end

end
