#!/usr/bin/env ruby

require 'teleinfo'
require 'http'
require 'time'

teleinfo = Teleinfo::Parser.new(ARGF)
teleinfo_pusher_url = ENV['TI_URL']
raise "Missing ENV['TI_URL']. Please specify a complete URL" unless teleinfo_pusher_url 
puts "entering the loop"
loop do
  # {"adco":"040828033549","optarif":"HC","isousc":30,"hchc":29615255,"hchp":46445648,"ptec":"HC","iinst":1,"imax":41,"papp":310,"hhphc":"D","time":"2016-06-09T20:51:26Z"}
  frame = teleinfo.next
  hash_frame = {}
  frame_h = frame.to_hash
  if old?
    frame_h.each { |k,v| hash_frame[k.to_s] = v }
    hash_frame['time'] = Time.now.utc.iso8601
  else
    hash_frame['name'] = 'teleinfo'
    hash_frame['columns'] = frame_h.keys
    hash_frame['points'] = [frame_h.values]
    hash_frame = [hash_frame]
  end
  puts hash_frame.to_json
  puts
  if hash_frame['iinst'] || hash_frame['columns'].include?('iinst')
    begin
      resp = HTTP.post(teleinfo_pusher_url, json: hash_frame)
      puts resp.inspect
      puts resp.to_s
      puts "going to sleep…"
      sleep(5)
    rescue Exception => e
      puts "Exception caught!"
      puts e.inspect
    end
  else
    puts "Incomplete frame, fast skip"
  end
end

