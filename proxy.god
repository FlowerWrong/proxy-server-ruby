God.watch do |w|
  w.name = 'proxy'
  w.start = 'ruby ./proxy.rb'
  w.keepalive
  w.log = './log/proxy_server.log'
end
