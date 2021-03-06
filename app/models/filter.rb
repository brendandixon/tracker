# == Schema Information
#
# Table name: filters
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  content    :text
#  area       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#

class Filter < ActiveRecord::Base
  attr_accessible :area, :content, :name, :user_id, :user

  belongs_to :user

  serialize :content

  after_initialize :ensure_content
  after_save :ensure_content

  validates_presence_of :area
  validates_presence_of :name
  validates_uniqueness_of :name, scope: [:area, :user_id]

  scope :for_area, lambda{|area| where(area: area) }
  scope :for_user, lambda{|user| where(user_id: user.is_a?(User) ? user.id : user) }
  scope :for_all_users, where('user_id IS NULL')

  scope :in_name_order, lambda{|dir = 'ASC'| order("name #{dir}")}

  def empty?
    self.content.empty?
  end

  def hash
    self.to_hash.hash
  end

  def to_hash(*args)
    args = args.map{|v| v.to_sym}
    self.attributes.reject{|k, v| (args.present? && !args.include?(k.to_sym)) || [:created_at, :updated_at].include?(k.to_sym) }
  end

  private

  def ensure_content
    self.content ||= {}
    self.content = self.content.symbolize_keys
  end

end
