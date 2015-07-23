require 'rest-client'
require 'awesome_print'

require 'yaml'
require 'active_support/core_ext/hash/keys'
PROXY_CONFIG = YAML.load(File.open(File.dirname(__FILE__) + '/config/setting.yml')).symbolize_keys
default_config = PROXY_CONFIG[:proxy].symbolize_keys

default_config[:hosts].split(' ').each do |host|
  RestClient.proxy = "http://#{host}:8008"
  begin
    res = RestClient.get 'http://api.douban.com/v2/movie/subject/24847343'
    ap res
  rescue RestClient::ExceptionWithResponse => err
    p err.response
  end
end
