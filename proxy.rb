#!/usr/bin/env ruby

require 'socket'
require 'uri'
require 'logging'

$log = Logging.logger(STDOUT)
$log.level = :warn

class Proxy
  def run port
    begin
      # See http://ruby-doc.org/stdlib-2.2.2/libdoc/socket/rdoc/TCPServer.html
      # 创建代理服务器
      @tcp_server = TCPServer.new port

      $log.warn 'TCPServer started'

      # Handle every request in another thread
      loop do
        # Wait for a client to connect
        client = @tcp_server.accept
        Thread.new client, &method(:handle_request)
      end

    # CTRL + C
    rescue Interrupt
      $log.warn 'Got Interrupt..'
    # Ensure that we release the socket on errors
    ensure
      if @tcp_server
        @tcp_server.close
        $log.warn 'Socket closed..'
      end
      $log.warn 'Quitting.'
    end
  end

  def handle_request tcp_client
    # Client request
    request_line = tcp_client.readline
    $log.warn '-----------------------------------------------------------------'
    $log.warn request_line
    verb    = request_line[/^\w+/]
    url     = request_line[/^\w+\s+(\S+)/, 1]
    version = request_line[/HTTP\/(1\.\d)\s*$/, 1]
    uri     = URI::parse url

    # See http://ruby-doc.org/stdlib-2.2.2/libdoc/socket/rdoc/TCPSocket.html
    # 发起代理请求
    to_server = TCPSocket.new(uri.host, (uri.port.nil? ? 80 : uri.port))
    to_server.write("#{verb} #{uri.path}?#{uri.query} HTTP/#{version}\r\n")

    content_len = 0

    loop do
      line = tcp_client.readline
      content_len = $1.to_i if line =~ /^Content-Length:\s+(\d+)\s*$/

      # Strip proxy headers
      if line =~ /^proxy/i
        next
      elsif line.strip.empty?
        to_server.write("Connection: close\r\n\r\n")
        to_server.write(tcp_client.read(content_len)) if content_len >= 0
        break
      else
        to_server.write(line)
      end
    end

    # 返回数据到客户端
    server_data_len = 0
    while line = to_server.gets
      tcp_client.write line
      server_data_len = $1.to_i if line =~ /^Content-Length:\s+(\d+)\s*$/
      break if line.strip.empty?
    end

    # To fix none complete data
    payload = to_server.read(server_data_len) if server_data_len
    tcp_client.write payload if payload

    # 关闭客户端
    tcp_client.close

    # 关闭代理请求
    to_server.close
  end
end

# 获取 port 参数
if ARGV.empty?
  port = 8008
elsif ARGV.size == 1
  port = ARGV[0].to_i
else
  $log.warn 'Usage: proxy.rb [port]'
  exit 1
end

Proxy.new.run port
