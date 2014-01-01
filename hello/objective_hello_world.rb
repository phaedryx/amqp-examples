#!/usr/bin/env ruby
# encoding: utf-8

require "rubygems"
require "amqp"

class Producer
  def initialize(exchange)
    @exchange = exchange
  end

  def publish(message, queue_name)
    @exchange.publish(message, :routing_key => queue_name)
  end
end

class Consumer
  def initialize(queue)
    queue.subscribe &method(:consume_message)
  end

  def consume_message(message)
    puts "Consumer received a message: #{message}"
  end
end

AMQP.start("amqp://127.0.0.1:5672") do |connection|
  channel  = AMQP::Channel.new(connection)
  queue    = channel.queue("amqpgem.examples.helloworld", :auto_delete => true)
  exchange = channel.direct("")

  producer = Producer.new(exchange)
  consumer = Consumer.new(queue)

  producer.publish("Hello World!", queue.name)

  EM.add_timer(2) do
    puts "Disconnecting..."
    connection.close { EM.stop }
  end
end
