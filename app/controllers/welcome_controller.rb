class WelcomeController < ApplicationController
  skip_authorization_check
  def index
    @events = Event.all
  end
end
