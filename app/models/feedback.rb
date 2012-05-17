class Feedback < ActiveRecord::Base
	validates_presence_of :description, :message => "cannot be empty"
end