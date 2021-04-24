# frozen_string_literal: true

# About page questions and answers.
class Faq < ApplicationRecord
  # Constants
  ORDERS = {
    "displayed desc" => "faqs.displayed desc",
    "displayed" => "faqs.displayed",
    "position desc" => "faqs.position desc",
    "position" => "faqs.position nulls last"
  }
  DEFAULT_ORDER = "faqs.position nulls last"

  # Concerns
  include Deletable
  include Searchable

  # Scopes
  scope :displayed, -> { current.where(displayed: true) }

  # Validations
  validates :question, :answer, presence: true

  # Methods
  def self.searchable_attributes
    %w(question answer)
  end
end
