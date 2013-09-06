class AddTipsToReferences < ActiveRecord::Migration
  def change
    ReferenceType.with_name('GitHub').first.update_attribute(:tip, 'Provide the path of the URL (e.g., aws/aws-cli/issues/328')
    ReferenceType.with_name('Issue#').first.update_attribute(:tip, 'Provide the Issue number (e.g., SDK-28)')
    ReferenceType.with_name('Ticket#').first.update_attribute(:tip, 'Provide the Ticket number (e.g., 0024361700)')
  end
end
