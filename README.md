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

```ruby
mina setup
mina deploy
```
