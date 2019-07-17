require 'twitter'
require 'dotenv'
require 'pry'

require_relative './journalists.rb'

Dotenv.load('../.env')

def initial
  @client = login_twitter
  @client_stream = login_twitter_stream
  @journalists = journalists
  @hashtbonjour = '#bonjour_monde'
  @thp = "@the_hacking_pro"
end

def login_twitter 
  client = Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
    config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
    config.access_token        = ENV["TWITTER_ACCESS_TOKEN"]
    config.access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
  end
  return client
end

def login_twitter_stream
  client_stream = Twitter::Streaming::Client.new do |config|
    config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
    config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
    config.access_token        = ENV["TWITTER_ACCESS_TOKEN"]
    config.access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
  end
  return client_stream
end

def say_hello
  journalists.sample(5).each do |i|
    @client.update("#{i} Merci pour votre travail ! #{@thp} #{@hashtbonjour}")
    puts"#{i}"
  end
end

def like_hello
  @client.search("#{@hashtbonjour}", result_type: "recent").take(25).collect do |tweet|
    @client.favorite(tweet)
    puts "#{tweet.user.screen_name} : #{tweet.text}"
  end
end

def follow_hello
  @client.search("#{@hashtbonjour}", result_type: "recent").take(25).collect do |tweet|
    unless tweet.user == @client.user || @client.friends.include?(tweet.user)
      @client.follow(tweet.user)
      puts "#{tweet.user.screen_name}"
    end
  end
end

def stream_hello
  login_twitter_stream
  @client_stream.filter(track: "#{@hashtbonjour}") do |tweet|
    unless tweet.user == @client.user
    @client.favorite!(tweet)
    @client.follow(tweet.user)
    puts "#{tweet.user.screen_name} : #{tweet.text}"
    end
  end
end

def perform
  initial
  follow_hello
end

perform