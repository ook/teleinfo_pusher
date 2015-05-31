#!/usr/bin/env ruby

require 'teleinfo'
require 'http'

teleinfo = Teleinfo::Parser.new(ARGF)
teleinfo_pusher_url = ENV['TI_URL']
raise "Missing ENV['TI_URL']. Please specify a complete URL" unless teleinfo_pusher_url 
puts "entering the loop"
loop do
  frame = teleinfo.next
  hash_frame = {}
  frame.to_hash.each { |k,v| hash_frame[k.to_s] = v }
  puts hash_frame.to_json
  puts
  if hash_frame['iinst']
    resp = HTTP.post(teleinfo_pusher_url, json: hash_frame)
    puts resp.inspect
    puts resp.body.read
    puts "going to sleep…"
    sleep(5)
  else
    puts "Incomplete frame, fast skip"
  end
end

