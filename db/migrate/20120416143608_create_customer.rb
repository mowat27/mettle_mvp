class CreateCustomer < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.string :email_address
      t.timestamps
    end
  end
end
