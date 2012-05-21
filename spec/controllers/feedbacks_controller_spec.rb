require 'spec_helper'

describe FeedbacksController do

  let(:valid_attributes) do
    {
      :description => "What a great web site.",
      :email_address => "bob@example.com",
      :send_newsletter => true
    }
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Feedback" do
        expect {
          post :create, :feedback => valid_attributes
        }.to change(Feedback, :count).by(1)
      end

      it "creates a new Feedback with description supplied" do
        post :create, :feedback => valid_attributes
        Feedback.last.description.should == valid_attributes[:description]
        Feedback.last.email_address.should == valid_attributes[:email_address]
        Feedback.last.send_newsletter.should == valid_attributes[:send_newsletter]
      end

      it "renders the homepage" do
        post :create, :feedback => valid_attributes
        response.should redirect_to(try_path)
      end

      it "adds a flash notice" do
        post :create, :feedback => valid_attributes
        flash[:notice].should == "Thank you for your feedback."
      end

      context "on error" do
        it "adds a flash notice" do
          invalid_attributes = {}
          post :create, :feedback => invalid_attributes
          flash[:alert].should match(/There was a problem with your feedback/)
          flash[:alert].should match(/description cannot be empty/)
        end
        it "redirects to new" do
          invalid_attributes = {}
          post :create, :feedback => invalid_attributes
          response.should redirect_to(new_feedback_path)
        end
      end
    end
  end
end