class Agreement < ActiveRecord::Base

  # STEP 1 Fields:
  #   :data_user
  #   :data_user_type => 'individual', 'organization'
  #   :individual_institution_name
  #   # :individual_name => Not in schema, this is data_user
  #   :individual_title
  #   :individual_telephone
  #   # :individual_email => Not in schema, this is agreement.user.email
  #   :individual_address

  #   :organization_business_name
  #   :organization_contact_name
  #   :organization_contact_title
  #   :organization_contact_telephone
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

  # Callbacks
  after_create :set_token

  STATUS = ["submitted", "approved", "resubmit", "expired", "started"].collect{|i| [i,i]}

  attr_accessor :draft_mode, :full_mode

  # Concerns
  include Deletable, Latexable

  # Named Scopes
  scope :search, lambda { |arg| where( 'agreements.user_id in (select users.id from users where LOWER(users.first_name) LIKE ? or LOWER(users.last_name) LIKE ? or LOWER(users.email) LIKE ? )', arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%') ).references(:users) }
  scope :expired, -> { where("agreements.expiration_date IS NOT NULL and agreements.expiration_date < ?", Date.today) }
  scope :not_expired, -> { where("agreements.expiration_date IS NULL or agreements.expiration_date >= ?", Date.today) }
  scope :with_tag, lambda { |arg| where('agreements.id in (select agreement_tags.agreement_id from agreement_tags where agreement_tags.tag_id = ?)', arg).references(:agreement_tags) }
  scope :regular_members, -> { where("agreements.user_id in (select users.id from users where users.deleted = ? and users.aug_member = ? and users.core_member = ?)", false, false, false).references(:users) }

  # Model Validation
  validates_presence_of :user_id
  validates_uniqueness_of :duly_authorized_representative_token, allow_nil: true

  validates_presence_of :reviewer_signature, :approval_date, :expiration_date, if: :approved?
  validates :reviewer_signature, length: { minimum: 20, tokenizer: lambda { |str| (JSON.parse(str) rescue []) }, too_short: "can't be blank" }, if: :approved?

  validates_presence_of :comments, if: :resubmission_required?

  validates_presence_of :data_user, if: :step1?
  validates_presence_of :data_user_type, if: :step1?
  validates :data_user_type, inclusion: { in: %w(individual organization), message: "\"%{value}\" is not a valid data user type" }, if: :step1?
  validates_presence_of :individual_institution_name, :individual_title, :individual_telephone, :individual_address, if: :step1_and_individual?
  validates_presence_of :organization_business_name, :organization_contact_name, :organization_contact_title, :organization_contact_telephone, :organization_contact_email, :organization_address, if: :step1_and_organization?

  validates_presence_of :title_of_project, :specific_purpose, if: :step2?
  validates_length_of :specific_purpose, minimum: 20, too_short: "is lacking sufficient detail and must be at least %{count} words.", tokenizer: lambda {|str| str.scan(/\w+/) }, if: :step2?
  validates_presence_of :datasets, if: :step2?
  validates_presence_of :intended_use_of_data, :data_secured_location, :secured_device, :human_subjects_protections_trained, if: :step2?

  validates_presence_of :has_read_step3, if: :step3?
  validates_presence_of :posting_permission, if: :step3?
  validates :posting_permission, inclusion: { in: %w(all name_only none), message: "\"%{value}\" is not a valid posting permission" }, if: :step3?

  validates_presence_of :signature, :signature_print, :signature_date, if: :step4_and_authorized?
  validates :signature, length: { minimum: 20, tokenizer: lambda { |str| (JSON.parse(str) rescue []) }, too_short: "can't be blank" }, if: :step4_and_authorized?

  validates_presence_of :duly_authorized_representative_signature, :duly_authorized_representative_signature_print, :duly_authorized_representative_signature_date, :duly_authorized_representative_title, if: :step4_and_not_authorized?
  validates :duly_authorized_representative_signature, length: { minimum: 20, tokenizer: lambda { |str| (JSON.parse(str) rescue []) }, too_short: "can't be blank" }, if: :step4_and_not_authorized?

  validates_presence_of :irb_evidence_type, if: :step5?
  validates :irb_evidence_type, inclusion: { in: %w(has_evidence no_evidence), message: "\"%{value}\" is not a valid evidence type" }, if: :step5?

  validates_presence_of :irb, if: :step5_and_has_evidence?

  # Model Relationships
  belongs_to :user
  has_many :requests
  has_many :datasets, -> { where deleted: false }, through: :requests
  has_many :reviews, -> { joins(:user).order('lower(substring(users.first_name from 1 for 1)), lower(substring(users.last_name from 1 for 1))') }
  has_many :agreement_events, -> { order( :event_at ) }
  has_many :agreement_tags
  has_many :tags, -> { where(deleted: false).order(:name) }, through: :agreement_tags
  has_many :agreement_transactions, -> { order(id: :desc) }
  has_many :agreement_transaction_audits

  # Agreement Methods

  def copyable_attributes
    self.attributes.reject{|key, val| ['id', 'deleted', 'created_at', 'updated_at', 'reviewer_signature', 'approval_date', 'expiration_date', 'comments', 'has_read_step3', 'has_read_step5', 'current_step', 'dua', 'executed_dua'].include?(key.to_s)}
  end

  def dataset_ids=(ids)
    self.datasets = Dataset.where( id: ids )
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

  def academic?
    self.data_user_type == 'individual'
  end

  def commercial?
    self.data_user_type == 'organization'
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
    self.add_reviewers!
    self.reviews.each do |review|
      UserMailer.daua_submitted(review.user, self).deliver_later if Rails.env.production?
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
    dup_agreement.duly_authorized_representative_token = nil
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
    Agreement.create_signature_png(self.duly_authorized_representative_signature, File.join(folder, "duly_authorized_representative_signature.png"))
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

  def duly_authorized_representative_valid?
    self.duly_authorized_representative_signature.present? and self.duly_authorized_representative_signature_print.present? and self.duly_authorized_representative_signature_date.present? and self.duly_authorized_representative_title.present?
  end

  def send_daua_signed_email!
    unless Rails.env.test? or Rails.env.development?
      pid = Process.fork
      if pid.nil? then
        # In child
        UserMailer.daua_signed(self).deliver_later if Rails.env.production?
        Kernel.exit!
      else
        # In parent
        Process.detach(pid)
      end
    end
  end

  def authorized_signature_date
    self.unauthorized_to_sign? ? self.duly_authorized_representative_signature_date : self.signature_date
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

  def step4_and_authorized?
    self.unauthorized_to_sign == false and self.step4?
  end

  def step4_and_not_authorized?
    self.unauthorized_to_sign == true and self.step4?
  end

  def step5?
    self.validate_step?(5)
  end

  def step5_and_has_evidence?
    self.irb_evidence_type == 'has_evidence' and self.step5?
  end

  def self.latex_safe(mystring)
    self.new.latex_safe(mystring)
  end

  private

  def set_token
    begin
      self.update_column :duly_authorized_representative_token, Digest::SHA1.hexdigest(Time.now.usec.to_s) if self.duly_authorized_representative_token.blank?
    rescue
    end
  end

end
