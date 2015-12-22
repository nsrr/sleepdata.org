namespace :challenges do
  desc 'Export Flow Limitation challenge to CSV'
  task export_flow_limitation: :environment do
    puts 'Started Export for Flow Limitation'
    challenge = Challenge.find_by_slug 'flow-limitation'
    questions = []
    challenge.signal_map.each_with_index do |range, index|
      number = format('%02d', index + 1)
      range.collect do |letter|
        question_name = "signal#{number}#{letter.downcase}"
        question = challenge.questions.find_by_name(question_name)
        questions << question
      end
    end

    tmp_folder = File.join('tmp', 'challenges')
    FileUtils.mkdir_p tmp_folder
    fl_csv = File.join(tmp_folder, "#{challenge.slug}.csv")

    CSV.open(fl_csv, 'wb') do |csv|
      csv << (%w(Email Name) + questions.collect(&:name))

      users = User.current.order(:email).where(id: challenge.answers.select(:user_id))
      user_count = users.count
      users.each_with_index do |u, index|
        print "\rExporting Data For: #{index + 1} of #{user_count} - #{u.email}   "
        user_row = [u.email, u.name]
        user_row += questions.collect do |question|
          answer = challenge.answers.where(question_id: question.id, user_id: u.id).first
          answer ? answer.response : nil
        end
        csv << user_row
      end
    end

    puts "\nExport Complete - #{fl_csv}"
  end

  desc 'Export Flow Limitation 2 challenge to CSV'
  task export_flow_limitation_2: :environment do
    puts 'Started Export for Flow Limitation 2'
    challenge = Challenge.find_by_slug 'flow-limitation-2'
    questions = []
    challenge.signal_map.each_with_index do |range, index|
      number = format('%02d', index + 1)
      range.collect do |letter|
        question_name = "signal#{number}#{letter.downcase}"
        question = challenge.questions.find_by_name(question_name)
        questions << question
      end
    end

    tmp_folder = File.join('tmp', 'challenges')
    FileUtils.mkdir_p tmp_folder
    fl_csv = File.join(tmp_folder, "#{challenge.slug}.csv")

    CSV.open(fl_csv, 'wb') do |csv|
      csv << (%w(Email Name) + questions.collect(&:name))

      users = User.current.order(:email).where(id: challenge.answers.select(:user_id))
      user_count = users.count
      users.each_with_index do |u, index|
        print "\rExporting Data For: #{index + 1} of #{user_count} - #{u.email}   "
        user_row = [u.email, u.name]
        user_row += questions.collect do |question|
          answer = challenge.answers.where(question_id: question.id, user_id: u.id).first
          answer ? answer.response : nil
        end
        csv << user_row
      end
    end

    puts "\nExport Complete - #{fl_csv}"
  end

  desc 'Create Flow Limitation Challenge'
  task create_flow_limitation_challenge: :environment do
    challenge = Challenge
                .where(slug: 'flow-limitation')
                .first_or_create(name: 'Flow Limitation', user_id: 1)
    challenge.signal_map.each_with_index do |letters, index|
      letters.each do |letter|
        number = format('%02d', index + 1)
        name = "signal#{number}#{letter.downcase}"
        challenge.questions.where(name: name).first_or_create
      end
    end
  end

  desc 'Create Flow Limitation Challenge 2'
  task create_flow_limitation_challenge_2: :environment do
    challenge = Challenge
                .where(slug: 'flow-limitation-2')
                .first_or_create(name: 'Flow Limitation 2', user_id: 1)
    challenge.signal_map.each_with_index do |letters, index|
      letters.each do |letter|
        number = format('%02d', index + 1)
        name = "signal#{number}#{letter.downcase}"
        challenge.questions.where(name: name).first_or_create
      end
    end
  end

  desc 'Add Survey URLs to Flow Limitation Challenges'
  task add_survey_urls: :environment do
    challenge = Challenge.find_by_slug 'flow-limitation'
    challenge.update survey_url: 'https://tryslice.io/survey/flow-limitation-challenge'

    challenge = Challenge.find_by_slug 'flow-limitation-2'
    challenge.update survey_url: 'https://tryslice.io/survey/flow-limitation-2-challenge'
  end
end
