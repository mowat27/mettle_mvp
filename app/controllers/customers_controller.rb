class CustomersController < ApplicationController
  # POST
  def create
    customer = Customer.new params[:customer]
    redirect_to :root if customer.save
  end
end