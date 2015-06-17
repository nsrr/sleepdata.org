namespace :agreements do

  desc 'Update existing agreements to new format'
  task clean: :environment do
    # Clean up step 4 signature for those who have signed
    Agreement.where.not(signature: ["",nil]).where(unauthorized_to_sign: true).update_all unauthorized_to_sign: false
  end

end
