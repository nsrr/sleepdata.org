class AddSurveyUrlToChallenges < ActiveRecord::Migration[4.2]
  def change
    add_column :challenges, :survey_url, :string
  end
end
