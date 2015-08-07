# README

## Dependency

```ruby
bundle install
```

## Usage

```ruby
god terminate
god -c proxy.god -D
```

## Proxy

```ruby
curl -i -x ip:8008 http://api.douban.com/v2/movie/subject/24847343
curl -x ip:8008 http://api.douban.com/v2/movie/subject/24847343 | python -m json.tool
```

## Deploy

##### Single server

```ruby
cp config/deploy.example.rb config/deploy.rb
cp config/setting.example.yml config/setting.yml
# And then edit it
mina setup
mina deploy
```

##### Multi servers

```ruby
cp config/deploy.example.rb config/deploy.rb
cp config/setting.example.yml config/setting.yml
# And then edit it
mina setup_all
mina deploy_all
```

## Health check

```ruby
ruby health_check.rb
```

## Linux port

```ruby
ps -aux | grep god
netstat -apn | grep 8008
```
