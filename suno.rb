# frozen_string_literal: true

require 'discordrb/webhooks'
require 'yaml'
require 'json'
require 'reverse_markdown'
require 'net/http'

config = YAML.load_file('config.yaml')

class DiscordSender
  def initialize(webhook_url)
    @client = Discordrb::Webhooks::Client.new(url: webhook_url)
  end

  def embed(&block)
    @client.execute do |_b|
      builder.add_embed(&block)
    end
  end

  def event_embed(event, base_url)
    embed do |e|
      e.title = event.title
      e.description = event.description
      e.url = base_url + "#event-#{event.start_time.to_i * 1000}"
      e.color = 0xF6D32D
      e.author = Discordrb::Webhooks::EmbedAuthor.new(name: event.perfomer)
      e.add_field(name: 'Language', value: event.language, inline: true)
      e.add_field(name: 'Category', value: event.category, inline: true)
      e.add_field(name: "Perormer's links", value: markdown_links(event.links), inline: true)
      e.add_field(name: 'Start time', value: discord_time(event.start_time), inline: true)
      e.add_field(name: 'End time', value: discord_time(event.end_time), inline: true)
    end
  end

  private

  def markdown_links(links)
    links.map do |name, url|
      "[#{name}](#{url})"
    end.join("\n")
  end

  def discord_time(time)
    "<t:#{time.to_i}:t> (<t:#{time.to_i}:R>)"
  end
end

class Event
  attr_accessor :title, :performer, :description, :start_time, :duration, :category, :language, :links

  def self.parse(json_event)
    event = Event.new
    %i[title performer language].each do |prop|
      event.send("#{prop}=", json_event[prop.to_s])
    end
    event.description = ReverseMarkdown.convert json_event['description']
    event.duration = json_event['duration'] * 60
    event.start_time = Time.at(json_event['start_time'])
    event.category = json_event['categories'].find { |c| !c.start_with?('toki: ') }
    event.links = json_event.slice('website', 'youtube', 'soundcloud', 'bandcamp', 'discord', 'spotify')
    event
  end

  def end_time
    @start_time + @duration
  end
end

class ScheduleFetcher
  def initialize(schedule_url, start_time)
    @url = URI.parse(schedule_url)
    @start_time = start_time
  end

  def fetch
    response = Net::HTTP.get_response(@url)
    json = JSON.parse(response.body)
    start = @start_time
    json.map do |event|
      event['start_time'] = start
      start += event['duration'] * 60
      next if event['performer'] == 'break'

      Event.parse(event)
    end
  end
end

fetcher = ScheduleFetcher.new('https://suno.pona.la/2023/tenpo/schedule.json', 1_710_670_300)
p fetcher.fetch
