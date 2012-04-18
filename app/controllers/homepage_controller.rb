class HomepageController < ApplicationController

  def index
    @customer = Customer.new
    @feedback = Feedback.new
  end

end