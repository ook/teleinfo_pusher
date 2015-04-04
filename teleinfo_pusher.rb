#!/usr/bin/env ruby

require 'teleinfo'
require 'aerospike'

class AerospikeConnector
  def initialize(namespace: ENV['AS_NAMESPACE'], host: '127.0.0.1', port: 3333)
    @namespace = namespace
    @client = Aerospike::Client.new(host, port)
    @key = Aerospike::Key.new(@namespace, 'teleinfo', 'raw')
  end

  def add_hash(hash)
    record = @client.get(@key)
    record[Time.now.utc.to_i] = hash
    @client.put(@key, record)
  end
end

teleinfo = Teleinfo::Parser.new(ARGF)
as = AerospikeConnector.new
puts "entering the loop"
loop do
  frame = teleinfo.next
  hash_frame = {}
  frame.to_hash.each { |k,v| hash_frame[k.to_s] = v }
  puts hash_frame.inspect
  puts
  if hash_frame['iinst']
    as.add_hash('teleinfo', 'teleinfo', hash_frame)
    puts "going to sleep…"
    sleep(15)
  else
    puts "Incomplete frame, fast skip"
  end
end

