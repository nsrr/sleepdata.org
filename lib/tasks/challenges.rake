namespace :challenges do

  desc 'Export Flow Limitation challenge to CSV'
  task export_flow_limitation: :environment do
    puts "Started Export for Flow Limitation"
    challenge = Challenge.find_by_slug 'flow-limitation'
    questions = []
    Challenge::SIGNAL_MAP.each_with_index do |range, index|
      number = "%02d" % (index + 1)
      range.collect do |letter|
        question_name = "signal#{number}#{letter.downcase}"
        question = challenge.questions.find_by_name(question_name)
        questions << question
      end
    end

    tmp_folder = File.join('tmp', 'challenges')
    FileUtils.mkdir_p tmp_folder
    fl_csv = File.join(tmp_folder, "#{challenge.slug}.csv")

    CSV.open(fl_csv, "wb") do |csv|
      csv << (['Email', 'Name'] + questions.collect(&:name))

      users = User.current.order(:email).where(id: challenge.answers.select(:user_id))
      user_count = users.count
      users.each_with_index do |u, index|
        print "\rExporting Data For: #{index + 1} of #{user_count} - #{u.email}              "
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

end
