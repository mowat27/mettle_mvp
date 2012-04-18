class Customer < ActiveRecord::Base
	validates_presence_of :email_address
end
