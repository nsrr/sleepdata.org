# Encapsulates challenges as well as responses to challenge questions.
class Challenge < ApplicationRecord
  # Concerns
  include Deletable

  # Named Scopes

  # Model Validation
  validates :name, :slug, :user_id, presence: true
  validates :slug, uniqueness: { scope: :deleted, case_sensitive: false }
  validates :slug, format: { with: /\A[a-z][a-z0-9\-]*\Z/ }

  # Model Relationships
  belongs_to :user
  has_many :questions, -> { where deleted: false }
  has_many :answers

  # Challenge Methods

  def to_param
    slug
  end

  def root_folder
    folder = (Rails.env.test? ? slug : id.to_s)
    File.join(CarrierWave::Uploader::Base.root, 'challenges', folder)
  end

  def images_folder
    File.join(root_folder, 'images')
  end

  def signal_map
    send "#{slug.tr('-', '_')}_signal_map"
  rescue
    []
  end

  def signal_count
    signal_map.count
  end

  def signal_name(number)
    send "#{slug.tr('-', '_')}_signal_name", number
  end

  private

  def flow_limitation_signal_map
    [('A'..'R'), ('A'..'V'), ('A'..'P'), ('A'..'N'), ('A'..'P'),
     ('A'..'S'), ('A'..'M'), ('A'..'M'), ('A'..'P'), ('A'..'M'),
     ('A'..'O'), ('A'..'S'), ('A'..'Q'), ('A'..'P'), ('A'..'M'),
     ('A'..'R'), ('A'..'P'), ('A'..'J'), ('A'..'S'), ('A'..'L'),
     ('A'..'M'), ('A'..'P'), ('A'..'M'), ('A'..'K'), ('A'..'M'),
     ('A'..'U'), ('A'..'O'), ('A'..'O'), ('A'..'L'), ('A'..'N')]
  end

  def flow_limitation_2_signal_map
    [('A'..'Q'), ('A'..'N'), ('A'..'M'), ('A'..'N'), ('A'..'M'),
     ('A'..'Q'), ('A'..'M'), ('A'..'N'), ('A'..'U'), ('A'..'N'),
     ('A'..'M'), ('A'..'U'), ('A'..'N'), ('A'..'Q'), ('A'..'U'),
     ('A'..'M'), ('A'..'Q'), ('A'..'P'), ('A'..'N'), ('A'..'M'),
     ('A'..'Q'), ('A'..'N'), ('A'..'P'), ('A'..'U'), ('A'..'M'),
     ('A'..'P'), ('A'..'M'), ('A'..'M'), ('A'..'P'), ('A'..'N')]
  end

  def flow_limitation_signal_name(number)
    "fl#{number}.png"
  end

  def flow_limitation_2_signal_name(number)
    "fl2-#{number}.png"
  end
end
