require 'spec_helper'

describe FeedbacksController do

  let(:valid_attributes){ {:description => "What a great web site."} }

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Feedback" do
        expect {
          post :create, :feedback => valid_attributes
        }.to change(Feedback, :count).by(1)
      end

      it "creates a new Feedback with email address supplied" do
        post :create, :feedback => valid_attributes
        Feedback.last.description.should == valid_attributes[:description]
      end

      it "renders the homepage" do
        post :create, :feedback => valid_attributes
        response.should redirect_to(:root)
      end

      it "adds a flash notice" do
        post :create, :feedback => valid_attributes
        flash[:notice].should == "Thank you for your feedback."
      end

      it "adds a flash notice" do
        invalid_attributes = {}
        post :create, :feedback => invalid_attributes
        flash[:alert].should == "There was a problem with your feedback."
      end
    end
  end
end