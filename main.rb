require 'rubygems'
require 'sinatra'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'sdfasdfasfasdf'

helpers do

  def calculate_total(cards)
    arr = cards.map{|e| e[1]}
    total = 0

    arr.each do |value|
      if value == 'A'
        total += 11
      elsif value.to_i == 0 # Jack, Queen, or King
        total += 10
      else
        total += value.to_i
      end
      arr.select{|e| e =='A'}.count.times do
        break if total <= 21
        total -= 10
      end
    end

      total
  end

  def card_image(card)
    suit = case card[0]
      when 'H' then 'hearts'
      when 'D' then 'diamonds'
      when 'S' then 'spades'
      when 'C' then 'clubs'
    end

    value = card[1]

    if ['J', 'K', 'Q', 'A'].include?(value)
      value = case card[1]
        when 'J' then 'jack'
        when 'Q' then 'queen'
        when 'K' then 'king'
        when 'A' then 'ace'
      end
    end

    "<img class='card_image' src='/images/cards/#{suit}_#{value}.jpg'>"
  end
end

before do
  @show_blackjack_buttons = true
end

get '/' do
  erb :welcome
end

post '/welcome' do
  redirect "/set_name"
end

get '/set_name' do
  erb :set_name
end

post '/set_name' do
  if params[:player_name].empty?
    @error = "Name is required"
    halt erb(:set_name)
  end
  session[:player_name] = params[:player_name]
  redirect '/game'
end

get '/game' do
  suits = ['H', 'D', 'S', 'C']
  cards = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'K', 'Q', 'A' ]
  session[:deck] = suits.product(cards).shuffle!

  session[:player_cards] = []
  session[:dealer_cards] = []

  2.times do
    session[:player_cards] << session[:deck].pop
    session[:dealer_cards] << session[:deck].pop
  end
  erb :game
end

post '/hit' do
  session[:player_cards] << session[:deck].pop
  player_total = calculate_total(session[:player_cards])
  if calculate_total(session[:player_cards]) > 21
    @error = "#{session[:player_name]} has busted!"
    @show_blackjack_buttons = false
  elsif player == 21
    @success = "#{session[:player_name]} has WON!!"
    @show_blackjack_buttons = false
  end
  erb :game
end

post '/stay' do
  @success = "#{session[:player_name]} has chosen to stay."
  @show_blackjack_buttons = false
  erb :game
end
