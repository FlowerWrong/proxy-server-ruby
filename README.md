# README

## Dependency

```ruby
gem install god
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
