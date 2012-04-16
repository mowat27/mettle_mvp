class HomepageController < ApplicationController

  def index
    @customer = Customer.new
  end

end