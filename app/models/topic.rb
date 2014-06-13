class Topic < ActiveRecord::Base

  attr_accessor :description

  # Concerns
  include Deletable

  # Callbacks
  after_create :create_first_comment

  # Named Scopes
  scope :search, lambda { |arg| where("name ~* ?", arg.to_s.split(/\s/).collect{|l| l.to_s.gsub(/[^\w\d%]/, '')}.collect{|l| "(\\m#{l})"}.join("|")) }
  scope :with_author, lambda { |arg| where("name ~* ?", arg.to_s.split(/\s/).collect{|l| l.to_s.gsub(/[^\w\d%]/, '')}.collect{|l| "(\\m#{l})"}.join("|")) }
  scope :not_banned, -> { where( "topics.user_id IN ( select users.id from users where users.banned = ?)", false ).references(:users) }

  # Model Validation
  validates_presence_of :name, :user_id
  validates_length_of :name, maximum: 40
  validates_presence_of :description, if: :new_record?

  # Model Relationships
  has_many :comments
  belongs_to :user

  def to_param
    "#{id}-#{name.parameterize}"
  end

  def editable_by?(current_user)
    not self.locked? and not self.user.banned? and (self.user == current_user or current_user.system_admin?)
  end

  def user_commented_recently?(current_user)
    self.comments.current.last and self.comments.current.last.user == current_user
  end

  private

  def create_first_comment
    self.comments.create( description: self.description, user_id: self.user_id )
  end

end
