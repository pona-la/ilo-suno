# frozen_string_literal: true

require 'reverse_markdown'
require 'active_record'

class Event < ActiveRecord::Base
  self.implicit_order_column = 'start_time'

  def self.parse(json_event)
    find_or_create_by(start_time: Time.at(json_event['start_time'])) do |event|
      event.title = json_event['title']
      event.performer = json_event['performer']
      event.language = json_event['language']
      event.description = ReverseMarkdown.convert json_event['description']
      event.duration = json_event['duration'] * 60
      event.category = json_event['categories'].find { |c| !c.start_with?('toki: ') }
      event.links = json_event.slice('website', 'youtube', 'soundcloud', 'bandcamp', 'discord', 'spotify')
    end
  end

  def end_time
    start_time + duration
  end
end
