class Theme < ActiveRecord::Base
  has_many :guides
  belongs_to :style
  has_and_belongs_to_many :images, :join_table => 'assets_themes', :association_foreign_key => 'asset_id'
end
