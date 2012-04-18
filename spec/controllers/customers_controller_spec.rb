require 'spec_helper'

describe CustomersController do

  let(:valid_attributes){ {:email_address => "bob@mettle.com"} }

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Customer" do
        expect {
          post :create, :customer => valid_attributes
        }.to change(Customer, :count).by(1)
      end

      it "creates a new customer with email address supplied" do
        post :create, :customer => valid_attributes
        Customer.last.email_address.should == valid_attributes[:email_address]
      end

      it "renders the homepage" do
        post :create, :customer => valid_attributes
        response.should redirect_to(:root)
      end
    end
  end
end