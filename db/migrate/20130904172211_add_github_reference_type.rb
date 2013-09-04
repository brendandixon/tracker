class AddGithubReferenceType < ActiveRecord::Migration
  def up
    ReferenceType.create(name: 'GitHub', url_pattern: 'https://github.com/:value:')
    ReferenceType.where(name: 'Contact Us#').first.update_attribute(:deprecated, true)
  end

  def down
  end
end
