class ModifyMemberships < ActiveRecord::Migration
  def self.up
    add_column :memberships, :authorized, :boolean, :default => false

  end

  def self.down
    remove_column :memberships, :authorized
  end
end
