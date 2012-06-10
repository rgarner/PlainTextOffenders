require "digest/sha1"

class Admin::AdminController < ApplicationController
  layout "admin"
  before_filter :login

  protected
  def login
    authenticate_or_request_with_http_basic do |username, password|
      # encrypt password to match with configured one
      hash_pass = Digest::SHA1.hexdigest(password)

      username == APP_CONFIG['admin_username'] && hash_pass == APP_CONFIG['admin_password']
    end
  end
end