God.watch do |w|
  w.name = 'proxy'
  w.start = 'ruby ./proxy.rb'
  w.keepalive
end
