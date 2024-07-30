# frozen_string_literal: true

require 'discordrb/webhooks'
require 'rails'

class DiscordSender
  def initialize(webhook_url)
    @client = Discordrb::Webhooks::Client.new(url: webhook_url)
  end

  def embed(&block)
    @client.execute do |b|
      b.add_embed(&block)
    end
  end

  def event_embed(event, next_up, base_url)
    embed do |e|
      e.title = event.title.truncate(256) if event.title.present?
      e.description = event.description.truncate(4096) if event.description.present?
      e.url = event_link(base_url, event.start_time)
      e.color = 0xF6D32D
      e.author = Discordrb::Webhooks::EmbedAuthor.new(name: event.performer.truncate(256)) if event.performer.present?
      e.add_field(name: 'Language', value: event.language.truncate(1024), inline: true) if event.language.present?
      e.add_field(name: 'Category', value: event.category.truncate(1024), inline: true) if event.category.present?
      e.add_field(name: "Performer's links", value: markdown_links(event.links).truncate(1024), inline: true) if event.links.present?
      e.add_field(name: 'Start time', value: discord_time(event.start_time).truncate(1024), inline: true)
      e.add_field(name: 'End time', value: discord_time(event.end_time).truncate(1024), inline: true)
      if next_up
        e.add_field(name: "Next up from #{next_up.performer} at #{discord_time(next_up.start_time)}".truncate(256),
                    value: "[#{next_up.title}](#{event_link(base_url, event.start_time)})".truncate(1024), inline: false)
      end
    end
  end

  private

  def event_link(base_url, time)
    base_url + "#event-#{time.to_i * 1000}"
  end

  def markdown_links(links)
    links.map do |name, url|
      "[#{name.capitalize}](#{url})"
    end.join("\n")
  end

  def discord_time(time)
    "<t:#{time.to_i}:t> (<t:#{time.to_i}:R>)"
  end
end
