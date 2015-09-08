require 'rubygems'
require 'sinatra'

BLACKJACK_AMOUNT = 21
DEALER_MIN = 17
POT_AMOUNT = 500

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
        break if total <= BLACKJACK_AMOUNT
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

  def winner!(msg)
    @show_blackjack_buttons = false
    @play_again = true
    session[:player_pot] = session[:player_pot] + session[:player_bet]
    @winner = msg
  end

  def loser!(msg)
    @show_blackjack_buttons = false
    @play_again = true
    session[:player_pot] = session[:player_pot] - session[:player_bet]
    @loser = msg
  end

  def tie!(msg)
    @show_blackjack_buttons = false
    @play_again = true
    @winner = msg
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
  session[:player_pot] = POT_AMOUNT
  erb :set_name
end

post '/set_name' do
  if params[:player_name].empty?
    @error = "Name is required"
    halt erb(:set_name)
  end
  session[:player_name] = params[:player_name]
  redirect '/bet'
end

get '/bet' do
  session[:player_bet] = nil
  erb :bet
end

post '/bet' do
  if params[:bet_amount].nil? || params[:bet_amount].to_i == 0
    @error = "Must make a bet."
    halt erb(:bet)
  elsif params[:bet_amount].to_i > session[:player_pot]
    @error = "Bet cannot be greater than current amount. (#{session[:player_pot]})"
    halt erb(:bet)
  else
    session[:player_bet] = params[:bet_amount].to_i
    redirect '/game'
  end
end

get '/game' do
  session[:turn] = session[:player_name]
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

get '/gameover' do
  erb :gameover
end

post '/hit' do
  session[:player_cards] << session[:deck].pop
  player_total = calculate_total(session[:player_cards])
  if calculate_total(session[:player_cards]) > BLACKJACK_AMOUNT
    loser!("#{session[:player_name]} has busted!")
  elsif player_total == BLACKJACK_AMOUNT
    winner!("#{session[:player_name]} hit Blackjack!!")
  end
  erb :game, layout: false
end

post '/stay' do
  @success = "#{session[:player_name]} has chosen to stay."
  @show_blackjack_buttons = false
  redirect '/game/dealer'
end

get '/game/dealer' do
  session[:turn] = "dealer"
  dealer_total = calculate_total(session[:dealer_cards])
  if dealer_total == BLACKJACK_AMOUNT
    loser!("Dealer hit Blackjack!")
  elsif dealer_total > BLACKJACK_AMOUNT
    loser!("Dealer busted. #{session[:player_name]} WINS!")
  elsif dealer_total >= DEALER_MIN
    redirect '/game/compare'
  else
    @show_dealer_hit = true
  end

  erb :game, layout: false
end

post '/game/dealer/hit' do
  session[:dealer_cards] << session[:deck].pop
  redirect '/game/dealer'
end

get '/game/compare' do
  @show_blackjack_buttons = false
  player_total = calculate_total(session[:player_cards])
  dealer_total = calculate_total(session[:dealer_cards])

  if player_total < dealer_total
    loser!("Sorry, #{session[:player_name]} you lost with a score of #{player_total}. Dealer had: #{dealer_total}")
  elsif player_total > dealer_total
    winner!("#{session[:player_name]} you WON with a score of #{player_total}. Dealer had: #{dealer_total}")
  else player_total == dealer_total
    tie!("Dealer: #{dealer_total}  Player: #{player_total} It's a tie!")
  end
    erb :game, layout: false
end
