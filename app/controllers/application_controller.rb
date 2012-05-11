class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :setup_sign_up_user
  before_filter :setup_feedback

  def setup_sign_up_user
    @customer = Customer.new
  end

  def setup_feedback
    @feedback = Feedback.new
  end

end
