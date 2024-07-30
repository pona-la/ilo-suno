# frozen_string_literal: true

require 'net/http'
require 'json'

# Fetches the schedule
class ScheduleFetcher
  def initialize(schedule_url, start_time)
    @url = URI.parse(schedule_url)
    @start_time = start_time
  end

  def fetch
    response = Net::HTTP.get_response(@url)
    json = JSON.parse(response.body)
    process_events(json)
  rescue StandardError => e
    puts "An error occurred while fetching schedule: #{e}"
  end

  def process_events(events)
    start = @start_time
    events.map do |json_event|
      event = process_event(json_event, start)
      start += json_event['duration'] * 60
      event
    end.compact
  end

  def process_event(event, start)
    return nil if event['performer'] == 'break'

    event['start_time'] = start
    Event.parse(event)
  end
end
