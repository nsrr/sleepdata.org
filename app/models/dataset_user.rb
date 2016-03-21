# frozen_string_literal: true

class DatasetUser < ActiveRecord::Base

  ROLES = [['Editor', 'editor'],['Viewer', 'viewer'],['Reviewer', 'reviewer']]

  # Model Validation
  validates_presence_of :user_id, :role

  # Model Relationships
  belongs_to :dataset
  belongs_to :user

end
