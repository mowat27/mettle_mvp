class CustomersController < ApplicationController

  def create
    if Customer.new( params[:customer] ).save  
      flash[:notice] = "Thank you for signing up."  
    else
      flash[:alert] = "There was a problem with your email address."
    end
    redirect_to :root 
  end

end