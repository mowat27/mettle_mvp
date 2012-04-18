class CreateFeedback < ActiveRecord::Migration
  def change
  	create_table :feedbacks do |table|
  		table.text :description  		
  	end
  end

end
