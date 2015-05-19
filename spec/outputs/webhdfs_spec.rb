# encoding: utf-8
require 'logstash/devutils/rspec/spec_helper'
require 'logstash/outputs/webhdfs'

describe 'outputs/webhdfs' do

  let(:event) do
    LogStash::Event.new(
        'message' => 'fanastic log entry',
        'source' => 'someapp',
        'type' => 'nginx',
        '@timestamp' => LogStash::Timestamp.now)
  end

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

    subject = LogStash::Plugin.lookup("output", "webhdfs").new('server' => '127.0.0.1:50070', 'path' => '/path/to/webhdfs.file')

    it 'should register' do
      expect { subject.register }.to_not raise_error
    end

    it 'should have default config values' do
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

end
