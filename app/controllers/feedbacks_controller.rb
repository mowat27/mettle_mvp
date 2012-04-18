class FeedbacksController < ApplicationController

  def create
    if Feedback.new( params[:feedback] ).save    
    	flash[:notice] = "Thank you for your feedback."
    else
    	flash[:alert] = "There was a problem with your feedback."
    end
    redirect_to :root 
  end

end