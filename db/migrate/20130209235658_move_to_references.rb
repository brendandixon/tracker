class MoveToReferences < ActiveRecord::Migration
  def up
    rt = ReferenceType.new
    rt.name = 'Contact Us#'
    rt.url_pattern = 'https://contactus.amazon.com/contact-us/ContactUsIssue.cgi?issue=:value:&profile=aws-dr-tools'
    rt.save
    
    Story.all.each do |story|
      if story.contact_us_number.present?
        r = Reference.create(reference_type_id: rt.id, value: story.contact_us_number)
        story.references << r
        story.save
      end
    end
  end

  def down
  end
end
