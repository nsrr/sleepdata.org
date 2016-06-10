# frozen_string_literal: true

namespace :agreements do
  # TODO: Remove the following in 0.23.0
  desc 'Update tags for agreement events'
  task update_event_tags: :environment do
    puts "AgreementEventTags: #{AgreementEventTag.count}"
    AgreementEvent.where(event_type: 'tags_updated').each do |agreement_event|
      agreement_event.added_tag_ids.each do |tag_id|
        agreement_event.agreement_event_tags.where(tag_id: tag_id).first_or_create added: true
      end
      agreement_event.removed_tag_ids.each do |tag_id|
        agreement_event.agreement_event_tags.where(tag_id: tag_id).first_or_create added: false
      end
    end
    puts "AgreementEventTag set as Added: #{AgreementEventTag.where(added: true).count}"
    puts "AgreementEventTag set as Removed: #{AgreementEventTag.where(added: false).count}"
  end
  # TODO: End
end
