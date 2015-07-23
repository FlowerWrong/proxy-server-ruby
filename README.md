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
```

## Deploy

##### Single server

```ruby
cp config/deploy.rb.example config/deploy.rb
# And then edit it
mina setup
mina deploy
```

##### Multi servers

```ruby
cp config/deploy.rb.example config/deploy.rb
# And then edit it
mina setup_all
mina deploy_all
```
