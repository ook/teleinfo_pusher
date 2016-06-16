#!/usr/bin/env ruby

require 'teleinfo'
require 'http'
require 'time'

teleinfo = Teleinfo::Parser.new(ARGF)
teleinfo_pusher_url = ENV['TI_URL']
place = ENV['PLACE']

raise "Missing ENV['TI_URL']. Please specify a complete URL" unless teleinfo_pusher_url 
raise "Missing ENV['PLACE']. Please specify a name" unless place
puts "entering the loop"
loop do
  # {"adco":"040828033549","optarif":"HC","isousc":30,"hchc":29615255,"hchp":46445648,"ptec":"HC","iinst":1,"imax":41,"papp":310,"hhphc":"D","time":"2016-06-09T20:51:26Z"}
  frame = teleinfo.next
  next unless frame
  hash_frame = frame.to_hash
  puts hash_frame.inspect
  influx_data = hash_frame.map do |(k,v)|
    # {:adco=>"040828033549", :optarif=>"HC", :isousc=>30, :hchc=>29653606, :hchp=>46493037, :ptec=>"HP", :iinst=>4, :imax=>41, :papp=>1030, :hhphc=>"D"}
    next if k == :adco
    "power,adco=#{hash_frame[:adco]},place=#{place} #{k}=#{v}"
  end
  puts influx_data
  next unless hash_frame.key?(:iinst)
  hash_frame = {}
  begin
    resp = HTTP.post(teleinfo_pusher_url, data: influx_data)
    puts resp.inspect
    puts resp.to_s
    puts "going to sleep…"
    sleep(5)
  rescue Exception => e
    puts "Exception caught!"
    puts e.inspect
  end
end

