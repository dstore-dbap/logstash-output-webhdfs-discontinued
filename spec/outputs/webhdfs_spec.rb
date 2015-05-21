# encoding: utf-8
require 'logstash/devutils/rspec/spec_helper'
require 'logstash/outputs/webhdfs'
require 'webhdfs'

describe 'outputs/webhdfs' do

  webhdfs_server = 'localhost'
  webhdfs_port = 50070
  webhdfs_user = 'hadoop'
  path_to_testlog = '/user/hadoop/test.log'
  current_logfile_name = '/user/hadoop/test.log'

  event = LogStash::Event.new(
        'message' => 'Hello world!',
        'source' => 'out of the blue',
        'type' => 'generator',
        'host' => 'localhost',
        '@timestamp' => LogStash::Timestamp.now)

  config =  { 'server' => webhdfs_server + ':' + webhdfs_port.to_s,
              'user' => webhdfs_user,
              'path' => path_to_testlog }

  client = WebHDFS::Client.new(webhdfs_server, webhdfs_port, webhdfs_user)

  context 'when initializing' do

    it 'should fail to register without required values' do
      configuration_error = false
      begin
        LogStash::Plugin.lookup("output", "webhdfs").new()
      rescue LogStash::ConfigurationError
        configuration_error = true
      end
      insist { configuration_error } == true
    end

    it 'should register' do
      subject = LogStash::Plugin.lookup("output", "webhdfs").new(config)
      expect { subject.register }.to_not raise_error
    end

    it 'should have default config values' do
      subject = LogStash::Plugin.lookup("output", "webhdfs").new(config)
      insist { subject.idle_flush_time } == 1
      insist { subject.flush_size } == 500
      insist { subject.open_timeout } == 30
      insist { subject.read_timeout } == 30
      insist { subject.use_httpfs } == false
      insist { subject.retry_known_errors } == true
      insist { subject.retry_interval } == 0.5
      insist { subject.retry_times } == 5
      insist { subject.snappy_bufsize } == 32768
      insist { subject.snappy_format } == 'stream'
      insist { subject.remove_at_timestamp } == true
    end
  end

  context 'when writing messages' do
    it 'should write 100 messages uncompressed' do
      current_logfile_name = path_to_testlog
      config['compression'] = 'none'
      subject = LogStash::Plugin.lookup("output", "webhdfs").new(config)
      subject.register
      for _ in 0..99
        subject.receive(event)
      end
      subject.teardown
      insist { client.read(current_logfile_name).lines.count } == 100
    end

    it 'should write 100 messages gzip compressed' do
      current_logfile_name = path_to_testlog + ".gz"
      config['compression'] = 'gzip'
      subject = LogStash::Plugin.lookup("output", "webhdfs").new(config)
      subject.register
      for _ in 0..99
        subject.receive(event)
      end
      subject.teardown
      insist { Zlib::Inflate.new(window_bits=47).inflate(client.read(current_logfile_name)).lines.count } == 100
    end

    after :each do
      client.delete(current_logfile_name)
    end

  end

end
