# frozen_string_literal: true

class TopicTag < ActiveRecord::Base

  belongs_to :topic
  belongs_to :tag

end
