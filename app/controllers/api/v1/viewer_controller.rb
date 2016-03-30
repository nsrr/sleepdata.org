# frozen_string_literal: true

# Controller to sign in viewer using token or allow public user.
class Api::V1::ViewerController < ApplicationController
  before_action :authenticate_user_from_token!
  skip_before_action :verify_authenticity_token
end
