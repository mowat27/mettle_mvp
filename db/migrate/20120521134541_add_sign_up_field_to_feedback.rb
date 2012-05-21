class AddSignUpFieldToFeedback < ActiveRecord::Migration
  def self.up
    add_column :feedbacks, :send_newsletter, :boolean
  end

  def self.down
    remove_column :feedbacks, :send_newsletter
  end
end
