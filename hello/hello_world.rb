#!/usr/bin/env ruby
# encoding: utf-8

require "rubygems"
require "amqp"

EM.run do
  # connects to the server running on localhost, with the default port (5672),
  # default username (guest), default password (guest) and virtual host ('/').
  connection = AMQP.connect(:host => '127.0.0.1')
  puts "Connected to AMQP broker. Running #{AMQP::VERSION} version of the gem..."

  # opens a new channel. AMQP is a multi-channeled protocol that uses channels
  # to multiplex a TCP connection.
  channel  = AMQP::Channel.new(connection)

  # declares a queue on the channel that we have just opened. Consumer
  # applications get messages from queues. We declared this queue with the
  # "auto-delete" parameter. Basically, this means that the queue will be deleted
  # when there are no more processes consuming messages from it.
  queue    = channel.queue("amqpgem.examples.helloworld", :auto_delete => true)

  # instantiates an exchange. Exchanges receive messages that are sent by producers.
  # Exchanges route messages to queues according to rules called bindings. In this
  # particular example, there are no explicitly defined bindings. The exchange that
  # we defined is known as the default exchange and it has implied bindings
  # to all queues.
  exchange = channel.direct("")

  # define a handler for incoming messages
  # AMQP::Queue#subscribe takes a block that will be called when a message arrives.
  # AMQP::Session#close closes the AMQP connection and runs a callback that stops
  # the EventMachine reactor
  queue.subscribe do |message|
    puts "Received a message: #{message}"
    puts "Disconnecting..."
    connection.close { EM.stop }
  end

  # publish a message
  exchange.publish "Hello, world!", :routing_key => queue.name
end
