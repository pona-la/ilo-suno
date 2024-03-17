# frozen_string_literal: true

class CreateEvent < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      t.string :title
      t.string :performer
      t.text :description
      t.datetime :start_time
      t.integer :duration
      t.string :category
      t.string :language
      t.json :links

      t.time :sent_at
      t.timestamps
    end
  end
end
