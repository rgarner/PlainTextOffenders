# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Plaintextoffenders::Application.initialize!

Capybara.save_and_open_page_path = 'tmp'
