#!/usr/bin/env ruby
# encoding: utf-8

require "rubygems"
require "amqp"

# AMQP.start is just a convenient way to do:
# EventMachine.run do
#   AMQP.connect(options) do |connection|
#     # ...
#   end
# end
AMQP.start("amqp://127.0.0.1:5672") do |connection|
  channel  = AMQP::Channel.new(connection)
  # a fanout exchange. A fanout exchange delivers messages to all of the queues that are bound to it
  exchange = channel.fanout("nba.scores")

  channel.queue("joe", :auto_delete => true).bind(exchange).subscribe do |message|
    puts "#{message} => joe"
  end

  channel.queue("aaron", :auto_delete => true).bind(exchange).subscribe do |message|
    puts "#{message} => aaron"
  end

  channel.queue("bob", :auto_delete => true).bind(exchange).subscribe do |message|
    puts "#{message} => bob"
  end

  exchange.publish("BOS 101, NYK 89").publish("ORL 85, ALT 88")

  # disconnect & exit after 2 seconds, cleanup
  EventMachine.add_timer(2) do
    exchange.delete

    connection.close { EventMachine.stop }
  end
end
