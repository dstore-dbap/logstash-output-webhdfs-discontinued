logstash-webhdfs
================

A logstash plugin to store events via webhdfs. 

Tested with v1.3.3 and v1.4.0.

Example configuration:

    output {
        webhdfs {
            workers => 2
            server => "your.nameno.de:14000"
            user => "flume"
            path => "/user/flume/logstash/dt=%{+Y}-%{+M}-%{+d}/logstash-%{+H}.log"
            flush_size => 500
            compress => "snappy"
            idle_flush_time => 10
            retry_interval => 0.5
        }
    }

For a complete list of options, see config section in source code.

This plugin has dependencies on:
* webhdfs module @<https://github.com/kzk/webhdfs>
* snappy module @<https://github.com/miyucy/snappy>

To test/use this plugin, refer to the developing section of the logstash github page @<https://github.com/elasticsearch/logstash>

Here is a rough plot:

    # Clone logstash git repository and switch to v1.3.3 tag:
    git clone https://github.com/elasticsearch/logstash.git
    cd logstash
    git checkout v1.3.3

    # Get jruby-complete-1.7.10.jar
    mkdir -p vendor/jar/ && cd vendor/jar/ && wget http://jruby.org.s3.amazonaws.com/downloads/1.7.10/jruby-complete-1.7.10.jar

    # Add webhdfs and snappy dependencies to logstash.gemspec
    cp logstash.gemspec logstash.gemspec.bak
    head -n -1 logstash.gemspec > logstash.gemspec.tmp
    echo '  #Webhdfs Deps' >> logstash.gemspec.tmp
    echo '  gem.add_runtime_dependency "webhdfs"' >> logstash.gemspec.tmp
    echo '  #Webhdfs Snappy Deps' >> logstash.gemspec.tmp
    echo '  gem.add_runtime_dependency "snappy"' >> logstash.gemspec.tmp
    tail -1 logstash.gemspec >> logstash.gemspec.tmp
    mv logstash.gemspec.tmp logstash.gemspec

    # Install dependencies
    USE_JRUBY=1 bin/logstash deps

    # Run logstash
    USE_JRUBY=1 bin/logstash agent -f /path/to/logstash/config -p /path/to/logstash-webhdfs/

## LICENSE
* License: Apache License, Version 2.0
