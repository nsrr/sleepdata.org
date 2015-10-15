class AddSurveyUrlToChallenges < ActiveRecord::Migration
  def change
    add_column :challenges, :survey_url, :string
  end
end
