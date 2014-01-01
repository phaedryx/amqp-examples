#!/usr/bin/env ruby
# encoding: utf-8

require "rubygems"
require "amqp"

AMQP.start("amqp://127.0.0.1:5672") do |connection|
  channel  = AMQP::Channel.new(connection)
  # topic exchange name can be any string
  exchange = channel.topic("weathr", :auto_delete => true)

  # subscribers
  channel.queue("", :exclusive => true) do |queue|
    queue.bind(exchange, :routing_key => "americas.north.#").subscribe do |headers, payload|
      puts "An update for North America: #{payload}, routing key: #{headers.routing_key}"
    end
  end
  channel.queue("americas.south").bind(exchange, :routing_key => "americas.south.#").subscribe do |headers, payload|
    puts "An update for South America: #{payload}, routing key: #{headers.routing_key}"
  end
  channel.queue("us.california").bind(exchange, :routing_key => "americas.north.us.ca.*").subscribe do |headers, payload|
    puts "An update for US/California: #{payload}, routing key: #{headers.routing_key}"
  end
  channel.queue("us.tx.austin").bind(exchange, :routing_key => "#.tx.austin").subscribe do |headers, payload|
    puts "An update for Austin, TX: #{payload}, routing key: #{headers.routing_key}"
  end
  channel.queue("it.rome").bind(exchange, :routing_key => "europe.italy.rome").subscribe do |headers, payload|
    puts "An update for Rome, Italy: #{payload}, routing key: #{headers.routing_key}"
  end
  channel.queue("asia.hk").bind(exchange, :routing_key => "asia.southeast.hk.#").subscribe do |headers, payload|
    puts "An update for Hong Kong: #{payload}, routing key: #{headers.routing_key}"
  end

  # publisher
  EM.add_timer(1) do
    exchange.publish("San Diego weather update",     :routing_key => "americas.north.us.ca.sandiego")
    exchange.publish("Berkeley weather update",      :routing_key => "americas.north.us.ca.berkeley")
    exchange.publish("San Francisco weather update", :routing_key => "americas.north.us.ca.sanfrancisco")
    exchange.publish("New York weather update",      :routing_key => "americas.north.us.ny.newyork")
    exchange.publish("São Paolo weather update",     :routing_key => "americas.south.brazil.saopaolo")
    exchange.publish("Hong Kong weather update",     :routing_key => "asia.southeast.hk.hongkong")
    exchange.publish("Kyoto weather update",         :routing_key => "asia.southeast.japan.kyoto")
    exchange.publish("Shanghai weather update",      :routing_key => "asia.southeast.prc.shanghai")
    exchange.publish("Rome weather update",          :routing_key => "europe.italy.roma")
    exchange.publish("Paris weather update",         :routing_key => "europe.france.paris")
  end


  show_stopper = Proc.new {
    connection.close { EM.stop }
  }

  EM.add_timer(2, show_stopper)
end
