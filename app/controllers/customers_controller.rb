class CustomersController < ApplicationController

  def create
    if Customer.new( params[:customer] ).save
      flash[:notice] = "Thank you for signing up."
      redirect_to try_path
    else
      flash[:alert] = "There was a problem with your email address."
      redirect_to new_customer_path
    end
  end
end