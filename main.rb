require 'rubygems'
require 'sinatra'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'sdfasdfasfasdf'

helpers do
  def calculate_total(cards)

  end
end

get '/test' do
  erb :"test/test"
end

get '/' do
  erb :set_name
end

post '/set_name' do
  session[:player_name] = params[:player_name]
  redirect '/game'
end

get '/game' do
  session[:deck] = [['2', 'Hearts'], ['4', 'Diamonds']]
  session[:player_cards] = []
  session[:player_cards] << session[:deck].pop
  erb :game
end
