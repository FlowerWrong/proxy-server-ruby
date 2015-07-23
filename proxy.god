God.watch do |w|
  w.name = 'proxy'
  w.start = "ruby #{File.join(File.dirname(__FILE__), 'proxy.rb')}"
  w.log = "#{File.join(File.dirname(__FILE__), 'log', 'proxy_server.log')}"
  w.keepalive(:memory_max => 150.megabytes,
              :cpu_max => 50.percent)
end
