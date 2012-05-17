class AddEmailToFeedbacks < ActiveRecord::Migration
def self.up
    add_column :feedbacks, :email_address, :string
  end

  def self.down
    remove_column :feedbacks, :email_address
  end
end
