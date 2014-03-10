class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable and :omniauthable
  devise :database_authenticatable, :registerable, :timeoutable,
         :recoverable, :rememberable, :trackable, :validatable

  # Concerns
  include Contourable, Deletable, TokenAuthenticatable

  # Callbacks
  before_save :ensure_authentication_token
  after_create :notify_system_admins

  # Named Scopes
  scope :aug_members, -> { current.where( aug_member: true ) }
  scope :system_admins, -> { current.where( system_admin: true ) }

  # Model Validation
  validates_presence_of :first_name, :last_name

  # Model Relationships
  has_many :agreements, -> { where deleted: false }
  has_many :datasets, -> { where deleted: false }
  has_many :dataset_file_audits
  has_many :lists
  has_many :tools

  # User Methods

  def all_datasets
    Dataset.current.with_editor( self.id )
  end

  def all_viewable_datasets
    Dataset.current.with_viewer( self.id )
  end

  def all_tools
    Tool.current.with_editor( self.id )
  end

  def avatar_url(size = 80, default = 'mm')
    gravatar_id = Digest::MD5.hexdigest(self.email.to_s.downcase)
    "//gravatar.com/avatar/#{gravatar_id}.png?&s=#{size}&r=pg&d=#{default}"
  end

  def name
    "#{first_name} #{last_name}"
  end

  def reverse_name
    "#{last_name}, #{first_name}"
  end

  def id_and_auth_token
    "#{self.id}-#{self.authentication_token}"
  end

  # Overriding Devise built-in active_for_authentication? method
  def active_for_authentication?
    super and not self.deleted?
  end

  def destroy
    super
    update_column :updated_at, Time.now
  end

  def apply_omniauth(omniauth)
    unless omniauth['info'].blank?
      self.first_name = omniauth['info']['first_name'] if first_name.blank?
      self.last_name = omniauth['info']['last_name'] if last_name.blank?
    end
    super
  end

  private

  def notify_system_admins
    User.system_admins.each do |system_admin|
      UserMailer.notify_system_admin(system_admin, self).deliver if Rails.env.production?
    end
  end

end
