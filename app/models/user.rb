# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class User < ActiveRecord::Base
  include CacheCleanser

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  # devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable
  devise :database_authenticatable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  # attr_accessible :title, :body
  attr_accessible :email, :filters, :password, :password_confirmation, :remember_me
  attr_accessible :roles
  
  has_many :filters
  has_and_belongs_to_many :roles

  default_scope includes(:filters, :roles)
  
  scope :in_email_order, lambda{|dir = 'ASC'| order("email #{dir}")}

  class<<self
    def active
      @active ||= User.in_email_order.all
    end
    
    def all_users
      @all_types ||= [['-', '']] + User.active.map{|u| [ u.email, u.id ] }
    end
    
    def refresh_cache
      @active = nil
      @all_types = nil
    end
  end

  def role?(role)
    return !!self.roles.map{|r| r.name}.include?(role.to_s.camelize)
  end

  def roles?(*roles)
    return (self.roles.map{|r| r.name} & roles.map{|r| r.to_s.camelize}).present?
  end

end
