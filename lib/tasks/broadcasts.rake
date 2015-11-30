namespace :broadcasts do
  desc 'Populate new broadcasts'
  task populate: :environment do
    ActiveRecord::Base.connection.execute("TRUNCATE broadcasts RESTART IDENTITY")
    Broadcast.create(user_id: 1, publish_date: '2015-01-30', title: 'Getting Started on the NSRR', description: "**Get started** with your [first tutorial](#{ENV['website_url']}/demo) for the NSRR.", published: true)
    Broadcast.create(user_id: 1, publish_date: '2015-03-11', title: 'NSRR Cross Dataset Query Interface', description: "**Learn** how to [search the NSRR](#{ENV['website_url']}/showcase/search-nsrr) using the NSRR Cross Dataset Query Interface.", published: true)
    Broadcast.create(user_id: 1, publish_date: '2015-03-11', title: 'Shaun Purcell - Researcher Showcase', description: "Learn about Shaun Purcell's work with data from the NSRR in the area of [Genetics of Sleep Spindles](#{ENV['website_url']}/showcase/shaun-purcell-genetics-of-sleep-spindles).", published: true)
    Broadcast.create(user_id: 1, publish_date: '2015-03-23', title: 'New Challenge', description: "Help fellow researchers by [participating](#{ENV['website_url']}/challenges/flow-limitation) in the Flow Limitation Challenge.", published: true)
    Broadcast.create(user_id: 1, publish_date: '2015-06-11', title: 'Matt Butler - Researcher Showcase', description: "Learn about Matt Butler's work with data from the NSRR in the area of [Novel Sleep Measures and Cardiovascular Risk](#{ENV['website_url']}/showcase/matt-butler-novel-sleep-measures-and-cardiovascular-risk).", published: true)
    Broadcast.create(user_id: 1, publish_date: '2015-09-09', title: 'Early Adopter Meeting', description: "The NSRR is [organizing a meeting](#{ENV['website_url']}/forum/43-nsrr-early-adopters-meeting-oct-9-2015) with a group of early adopters on October 9th in Boston.", published: true, archived: true)
    Broadcast.create(user_id: 1, publish_date: '2015-10-15', title: 'Our Second Challenge!', description: "Help fellow researchers by [participating](#{ENV['website_url']}/challenges/flow-limitation-2) in the **second** Flow Limitation Challenge.", published: true)
  end
end
