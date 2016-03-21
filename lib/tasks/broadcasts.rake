# frozen_string_literal: true

namespace :broadcasts do
  desc 'Populate new broadcasts'
  task populate: :environment do
    ActiveRecord::Base.connection.execute("TRUNCATE broadcasts RESTART IDENTITY")
    ActiveRecord::Base.connection.execute("TRUNCATE images RESTART IDENTITY")
    Broadcast.create(user_id: 1, publish_date: '2014-04-01', title: 'The NSRR launched!', short_description: 'Join us in celebrating our launch!', description: "Today we launched the NSRR.", published: true, archived: true)
    Broadcast.create(user_id: 1, publish_date: '2015-01-30', title: 'Getting Started on the NSRR', short_description: 'Get startedwith your first tutorial for the NSRR.', description: "**Get started** with your [first tutorial](#{ENV['website_url']}/demo) for the NSRR.", published: true)
    Broadcast.create(user_id: 1, publish_date: '2015-03-11', title: 'NSRR Cross Dataset Query Interface', short_description: 'Learn how to search the NSRR using the NSRR Cross Dataset Query Interface.', description: "**Learn** how to [search the NSRR](#{ENV['website_url']}/showcase/search-nsrr) using the NSRR Cross Dataset Query Interface.", published: true)
    Broadcast.create(user_id: 1, publish_date: '2015-03-11', title: 'Shaun Purcell - Researcher Showcase', short_description: "Learn about Shaun Purcell's work with data from the NSRR in the area of Genetics of Sleep Spindles.", description: "Learn about Shaun Purcell's work with data from the NSRR in the area of [Genetics of Sleep Spindles](#{ENV['website_url']}/showcase/shaun-purcell-genetics-of-sleep-spindles).", published: true)
    Broadcast.create(user_id: 1, publish_date: '2015-03-23', title: 'New Challenge', short_description: 'Help fellow researchers by participating in the Flow Limitation Challenge.', description: "Help fellow researchers by [participating](#{ENV['website_url']}/challenges/flow-limitation) in the Flow Limitation Challenge.", published: true)
    Broadcast.create(user_id: 1, publish_date: '2015-06-11', title: 'Matt Butler - Researcher Showcase', short_description: "Learn about Matt Butler's work with data from the NSRR in the area of Novel Sleep Measures and Cardiovascular Risk.", description: "Learn about Matt Butler's work with data from the NSRR in the area of [Novel Sleep Measures and Cardiovascular Risk](#{ENV['website_url']}/showcase/matt-butler-novel-sleep-measures-and-cardiovascular-risk).", published: true)
    Broadcast.create(user_id: 1, publish_date: '2015-09-09', title: 'Early Adopter Meeting', short_description: 'The NSRR is organizing a meeting with a group of early adopters on October 9th in Boston.', description: "The NSRR is [organizing a meeting](#{ENV['website_url']}/forum/43-nsrr-early-adopters-meeting-oct-9-2015) with a group of early adopters on October 9th in Boston.", published: true, archived: true)
    Broadcast.create(user_id: 1, publish_date: '2015-10-15', title: 'Our Second Challenge!', short_description: 'Help fellow researchers by participating in the second Flow Limitation Challenge.', description: "Help fellow researchers by [participating](#{ENV['website_url']}/challenges/flow-limitation-2) in the **second** Flow Limitation Challenge.", published: true)
    Broadcast.create(user_id: 1, publish_date: '2015-11-02', title: 'Over 20 TB of Data Shared', short_description: 'The NSRR has shared over 20 TB of data.', description: 'To date, we have shared over 20 TB of data to over 200 researchers across the globe.', published: true, archived: true)
  end
end
