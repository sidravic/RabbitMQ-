require "rubygems"
require "amqp"
require "em-websocket"

EventMachine.run do
  puts " EventMachine is running..."
  connection = AMQP.connect(:host => '127.0.0.1')
  channel = AMQP::Channel.new(connection)
  exchange = channel.fanout("testc")
  count = 0
  EventMachine::WebSocket.start(:host => '127.0.0.1', :port => 8080) do |ws|
    count += 1
    ws.onopen do
      puts "WebSocket opened"

      channel.queue("user_#{count}", :auto_delete =>  true).bind(exchange).subscribe do |payload|
        ws.send(payload)
      end


      exchange.publish("Testing one two three")
    end

    ws.onmessage do |msg|
      puts  "---- #{msg.inspect}----"
      exchange.publish(msg)
    end

    ws.onclose do
      puts "WEBSOCKET Closed"
    end
   end
end


