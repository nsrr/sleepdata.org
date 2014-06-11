class Topic < ActiveRecord::Base

  attr_accessor :description

  # Concerns
  include Deletable

  # Callbacks
  after_create :create_first_comment

  # Named Scopes
  scope :search, lambda { |arg| where("name ~* ?", arg.to_s.split(/\s/).collect{|l| l.to_s.gsub(/[^\w\d%]/, '')}.collect{|l| "(\\m#{l})"}.join("|")) }
  scope :with_author, lambda { |arg| where("name ~* ?", arg.to_s.split(/\s/).collect{|l| l.to_s.gsub(/[^\w\d%]/, '')}.collect{|l| "(\\m#{l})"}.join("|")) }

  # Model Validation
  validates_presence_of :name, :user_id
  validates_presence_of :description, if: :new_record?

  # Model Relationships
  has_many :comments
  belongs_to :user

  def to_param
    "#{id}-#{name.parameterize}"
  end

  private

  def create_first_comment
    self.comments.create( description: self.description, user_id: self.user_id )
  end

end
