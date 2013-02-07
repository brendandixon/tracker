class AddRoles < ActiveRecord::Migration
  def up
    ['Admin', 'Developer', 'ScrumMaster', 'Observer'].each do |role|
      Role.create(name: role)
    end
  end

  def down
  end
end
