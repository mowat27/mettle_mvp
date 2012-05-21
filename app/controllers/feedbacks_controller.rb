class FeedbacksController < ApplicationController

  def create
    feedback = Feedback.new( params[:feedback] )
    if feedback.save
    	flash[:notice] = "Thank you for your feedback."
      redirect_to try_path
    else
    	flash[:alert] = "There was a problem with your feedback: "
      feedback.errors.each {|attribute, error| flash[:alert] << "#{attribute} #{error} "}
      redirect_to new_feedback_path
    end
  end

end