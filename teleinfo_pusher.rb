#!/usr/bin/env ruby

require 'teleinfo'
require 'aerospike'

class AerospikeConnector
  def initialize(namespace: nil, host: '127.0.0.1', port: 3333)
    @namespace = namespace
    @client = Aerospike::Client.new(host, port)
  end

  def put_hash(set, key, hash)
    k = Aerospike::Key.new(@namespace, set, key)
    @client.put(k, hash)
  end
end

teleinfo = Teleinfo::Parser.new(ARGF)
as = AerospikeConnector.new(namespace: 'sweethome')
puts "entering the loop"
loop do
  frame = teleinfo.next
  hash_frame = {}
  frame.to_hash.each { |k,v| hash_frame[k.to_s] = v }
  puts hash_frame.inspect
  puts
  as.put_hash('teleinfo', Time.now.utc.to_i, hash_frame)
  puts "going to sleep…"
  sleep(15)
end

