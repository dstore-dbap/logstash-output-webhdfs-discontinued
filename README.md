logstash-webhdfs
================

A logstash plugin to store events via webhdfs.

Example configuration:

    output {
        hadoop_webhdfs {
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
The plugin has a dependency on the webhdfs module @<https://github.com/kzk/webhdfs>.

To test/use this plugin, refer to the developing section of the logstash github page @<https://github.com/elasticsearch/logstash>

## LICENSE
* License: Apache License, Version 2.0