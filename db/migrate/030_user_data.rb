class UserData < ActiveRecord::Migration
  def self.up
    add_column :users, :street, :string
    add_column :users, :city, :string
    add_column :users, :state, :string
    add_column :users, :postal_code, :string
    add_column :users, :phone, :string
    add_column :users, :signup_domain, :string
  end

  def self.down
    remove_column :users, :street
    remove_column :users, :city
    remove_column :users, :state
    remove_column :users, :postal_code
    remove_column :users, :phone
    remove_column :users, :signup_domain
  end
end
