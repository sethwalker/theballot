class Role < ActiveRecord::Base
  # acl_system2 support http://opensvn.csie.org/ezra/rails/plugins/dev/acl_system2/
  has_and_belongs_to_many :users
end
