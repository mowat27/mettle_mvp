class FeedbacksController < ApplicationController

  def create
    if Feedback.new( params[:feedback] ).save
    	flash[:notice] = "Thank you for your feedback."
      redirect_to :root
    else
    	flash[:alert] = "There was a problem with your feedback."
      redirect_to new_feedback_path
    end
  end

end