class Agreement < ActiveRecord::Base

  # STEP 1 Fields:
  #   :data_user
  #   :data_user_type => 'individual', 'organization'
  #   :individual_institution_name
  #   # :individual_name => Not in schema, this is data_user
  #   :individual_title
  #   :individual_telephone
  #   :individual_fax
  #   # :individual_email => Not in schema, this is agreement.user.email
  #   :individual_address

  #   :organization_business_name
  #   :organization_contact_name
  #   :organization_contact_title
  #   :organization_contact_telephone
  #   :organization_contact_fax
  #   :organization_contact_email
  #   :organization_address

  # STEP 2 Fields:
  #   :specific_purpose

  # STEP 3 Fields:
  #   :has_read_step3

  # Step 4 Fields:
  #   :posting_permission 'all', 'name_only', 'none'

  # STEP 5 Fields
  #   :has_read_step5

  serialize :history, Array

  mount_uploader :dua, PDFUploader
  mount_uploader :executed_dua, PDFUploader
  mount_uploader :irb, PDFUploader
  mount_uploader :printed_file, PDFUploader

  STATUS = ["submitted", "approved", "resubmit", "expired"].collect{|i| [i,i]}

  attr_accessor :draft_mode, :full_mode

  # Concerns
  include Deletable, Latexable

  # Named Scopes
  scope :search, lambda { |arg| where( 'agreements.user_id in (select users.id from users where LOWER(users.first_name) LIKE ? or LOWER(users.last_name) LIKE ? or LOWER(users.email) LIKE ? )', arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%') ).references(:users) }
  scope :expired, -> { where("agreements.expiration_date IS NOT NULL and agreements.expiration_date < ?", Date.today) }
  scope :not_expired, -> { where("agreements.expiration_date IS NULL or agreements.expiration_date >= ?", Date.today) }

  # Model Validation
  validates_presence_of :user_id
  # validates_presence_of :dua
  # validates_presence_of :executed_dua, if: :approved?

  validates_presence_of :reviewer_signature, :approval_date, :expiration_date, if: :approved?
  validates :reviewer_signature, length: { minimum: 20, tokenizer: lambda { |str| (JSON.parse(str) rescue []) }, too_short: "can't be blank" }, if: :approved?

  validates_presence_of :comments, if: :resubmission_required?

  validates_presence_of :data_user, if: :step1?
  validates_presence_of :data_user_type, if: :step1?
  validates :data_user_type, inclusion: { in: %w(individual organization), message: "\"%{value}\" is not a valid data user type" }, if: :step1?
  validates_presence_of :individual_institution_name, :individual_title, :individual_telephone, :individual_fax, :individual_address, if: :step1_and_individual?
  validates_presence_of :organization_business_name, :organization_contact_name, :organization_contact_title, :organization_contact_telephone, :organization_contact_fax, :organization_contact_email, :organization_address, if: :step1_and_organization?

  validates_presence_of :specific_purpose, if: :step2?
  validates_presence_of :datasets, if: :step2?

  validates_presence_of :has_read_step3, if: :step3?

  validates_presence_of :posting_permission, if: :step4?
  validates :posting_permission, inclusion: { in: %w(all name_only none), message: "\"%{value}\" is not a valid posting permission" }, if: :step4?

  validates_presence_of :has_read_step5, if: :step5?

  validates_presence_of :signature, :signature_print, :signature_date, if: :step6?
  validates :signature, length: { minimum: 20, tokenizer: lambda { |str| (JSON.parse(str) rescue []) }, too_short: "can't be blank" }, if: :step6?

  validates_presence_of :irb_evidence_type, if: :step7?
  validates :irb_evidence_type, inclusion: { in: %w(has_evidence no_evidence), message: "\"%{value}\" is not a valid evidence type" }, if: :step7?

  validates_presence_of :irb, if: :step7_and_has_evidence?

  validates_presence_of :title_of_project, :intended_use_of_data, :data_secured_location, :secured_device, if: :step8?

  # Model Relationships
  belongs_to :user
  has_many :requests
  has_many :datasets, -> { where deleted: false }, through: :requests
  has_many :reviews, -> { joins(:user).order('lower(substring(users.first_name from 1 for 1)), lower(substring(users.last_name from 1 for 1))') }
  has_many :agreement_events, -> { order( :event_at ) }

  # Agreement Methods

  def copyable_attributes
    self.attributes.reject{|key, val| ['id', 'deleted', 'created_at', 'updated_at', 'reviewer_signature', 'approval_date', 'expiration_date', 'comments', 'has_read_step3', 'has_read_step5', 'current_step', 'dua', 'executed_dua'].include?(key.to_s)}
  end

  def dataset_ids=(ids)
    self.datasets = Dataset.release_scheduled.where( id: ids )
  end

  def name
    self.user ? self.user.name : "##{self.id}"
  end

  def name_with_id
    self.user ? "##{self.id} - #{self.user.name}" : "##{self.id}"
  end

  def to_param
    "#{id}" + (self.user ? "-#{self.user.name.parameterize}" : '')
  end

  def agreement_number
    Agreement.where(user_id: self.user_id).order(:id).pluck(:id).index(self.id) + 1
  end

  def approved?
    self.status == 'approved'
  end

  def under_review?
    ['submitted'].include?(self.status)
  end

  def resubmission_required?
    self.status == 'resubmit'
  end

  def add_event!(message, current_user, status)
    self.history << { message: message, user_id: current_user.id, event_at: Time.now, status: status }
    self.status = status
    self.save
  end

  def daua_approved_email(current_user)
    self.add_event!('Data Access and Use Agreement approved.', current_user, 'approved')
    self.agreement_events.create event_type: 'principal_reviewer_approved', user_id: current_user.id, event_at: Time.now
    self.reviews.where( approved: nil ).destroy_all
    UserMailer.daua_approved(self, current_user).deliver_later if Rails.env.production?
    notify_admins_on_daua_progress(current_user)
  end

  def sent_back_for_resubmission_email(current_user)
    self.add_event!('Data Access and Use Agreement sent back for resubmission.', current_user, 'resubmit')
    self.agreement_events.create event_type: 'principal_reviewer_required_resubmission', user_id: current_user.id, event_at: Time.now, comment: self.comments
    UserMailer.sent_back_for_resubmission(self, current_user).deliver_later if Rails.env.production?
    notify_admins_on_daua_progress(current_user)
  end

  def notify_admins_on_daua_progress(current_user)
    other_admins = User.system_admins.where.not( id: current_user.id )
    other_admins.each do |admin|
      UserMailer.daua_progress_notification(self, admin).deliver_later if Rails.env.production?
    end
  end

  def daua_submitted
    User.system_admins.each do |system_admin|
      UserMailer.daua_submitted(system_admin, self).deliver_later if Rails.env.production?
    end
  end

  def add_reviewers!
    reviewers = User.current.where( id: self.datasets.collect{|d| d.reviewers.pluck(:id)}.flatten.uniq.compact )
    reviewers.each do |reviewer|
      self.reviews.where(user_id: reviewer.id).first_or_create
    end
  end

  def step_valid?(step)
    dup_agreement = self.dup
    dup_agreement.current_step = step
    dup_agreement.irb = self.irb
    dup_agreement.datasets = self.datasets
    dup_agreement.valid?
  end

  def has_irb_evidence?
    self.irb_evidence_type == 'has_evidence' and self.irb.size > 0
  end

  def no_irb_evidence?
    self.irb_evidence_type == 'no_evidence'
  end

  def draft_mode?
    self.draft_mode.to_s == '1'
  end

  def full_mode?
    self.full_mode.to_s == '1'
  end

  def fully_filled_out?
    self.full_mode = '1'
    self.valid?
  end

  def latex_partial(partial)
    File.read(File.join('app', 'views', 'agreements', 'latex', "_#{partial}.tex.erb"))
  end

  def generate_printed_pdf!
    jobname = "agreement_#{self.id}"
    output_folder = File.join('tmp', 'files', 'tex')
    file_tex = File.join('tmp', 'files', 'tex', jobname + '.tex')

    create_signature_pngs
    @agreement = self # Needed by Binding

    File.open(file_tex, 'w') do |file|
      file.syswrite(ERB.new(latex_partial('header')).result(binding))
      file.syswrite(ERB.new(latex_partial('body')).result(binding))
      file.syswrite(ERB.new(latex_partial('footer')).result(binding))
    end

    file_name = Agreement.generate_pdf(jobname, output_folder, file_tex)
    if File.exist?(file_name)
      self.printed_file = File.open(file_name)
      self.save(validate: false)
    end
  end

  def create_signature_pngs
    folder = File.join( Rails.root, 'tmp', 'files', 'agreements', "#{self.id}" )
    FileUtils.mkpath folder
    Agreement.create_signature_png(self.signature, File.join(folder, "signature.png"))
    Agreement.create_signature_png(self.reviewer_signature, File.join(folder, "reviewer_signature.png"))
  end

  def self.create_signature_png(signature, filename)
    canvas = ChunkyPNG::Canvas.new(300, 55)

    (JSON.parse(signature) rescue []).each do |hash|
      canvas.line( hash['mx'],  hash['my'], hash['lx'], hash['ly'], ChunkyPNG::Color.parse("#145394"))
    end
    png = canvas.to_image
    png.save(filename)
  end

  protected

  def save_mode?
    not draft_mode?
  end

  def validate_step?(step)
    self.full_mode? or (self.current_step == step and self.save_mode?)
  end

  def step1?
    self.validate_step?(1)
  end

  def step1_and_individual?
    self.data_user_type == 'individual' and self.step1?
  end

  def step1_and_organization?
    self.data_user_type == 'organization' and self.step1?
  end

  def step2?
    self.validate_step?(2)
  end

  def step3?
    self.validate_step?(3)
  end

  def step4?
    self.validate_step?(4)
  end

  def step5?
    self.validate_step?(5)
  end

  def step6?
    self.validate_step?(6)
  end

  def step7?
    self.validate_step?(7)
  end

  def step7_and_has_evidence?
    self.irb_evidence_type == 'has_evidence' and self.step7?
  end

  def step8?
    self.irb_evidence_type == 'no_evidence' and self.validate_step?(8)
  end

  def self.latex_safe(mystring)
    self.new.latex_safe(mystring)
  end

end
