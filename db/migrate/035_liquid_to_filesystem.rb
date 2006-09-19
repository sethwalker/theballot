class LiquidToFilesystem < ActiveRecord::Migration
  def self.up
    add_column :themes, :template, :string
    Theme.reset_column_information
    Theme.find(:all).each do |t|
      if t.name = 'Default'
        t.template = 'default.liquid'
      else
        t.template = 'cityscape.liquid'
      end
      t.save
    end
    remove_column :themes, :markup
  end

  def self.down
    markups = {}
    Theme.each do |t|
      markups[t.id] = File.read(File.join(RAILS_ROOT, "public/themes/#{t.template}"))
    end

    add_column :themes, :markup, :text
    Theme.reset_column_information
    remove_column :themes, :template
  end
end
