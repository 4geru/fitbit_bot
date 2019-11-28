require 'dotenv'
require 'fitbit_api'
require 'sinatra'
require 'pry'
Dotenv.load

get '/' do
  client = Client.new
  p client.auth_url
  redirect client.auth_url
end

get '/auth/fitbit_oauth2/callback' do
  client = Client.new

  client.get_token(params[:code])

  keys = {
    total: '🍓',
    deep: '🍐',
    light: '🍑',
    rem: '🍒',
    wake: '🍇'
  }

  res = client.sleep_logs Date.new(2019, 11, 28)
  stages = res['summary']['stages']
  total = stages['deep'] + stages['light'] + stages['rem']

  str = stages.map{ |key, value| time_to_s(key, value, keys[key.to_sym]) }.join("\n")
  str + total_time_to_s(total)
end

# api client
class Client < FitbitAPI::Client
  def initialize
    super(
      client_id: ENV['FITBIT_CLIENT_ID'],
      client_secret: ENV['FITBIT_SEACRET_KEY'],
      redirect_uri: 'http://localhost:3000/auth/fitbit_oauth2/callback'
    )
  end
end

# helper
def total_time_to_s(value)
  hours = value / 60
  minutes = value % 60
  time = format('%02d:%02d %s%s total', hours, minutes, '🍎' * hours, '🍏' * (minutes/ 30))
end

def time_to_s(key, value, emoji)
  hours = value / 60
  minutes = value % 60
  half = value/ 30
  _emoji = if half == 0
      '🌶️'
    else
      emoji * half
    end
  time = format('%02d:%02d %s %s', hours, minutes, _emoji, key)
end