require 'sinatra/base'
require 'redis'
require 'yaml'
require 'json'
require './tic_tac_toe.rb'
require './deep_blue.rb'


class TicTacToeApp < Sinatra::Base

  MESSAGES = {
    :game_started => 'Game started!',
    :game_won => 'The game has been won!',
    :took_turn => 'Turn has been executed.'
  }

  ERRORS = {
    :no_game => 'Start a game at /init-game first!',
    :no_move => 'Send a move [:move], a mark [:mark], and a game_id [:game_id].'
  }

  G_SESSION_EXP = 7200

  configure do
    @@redis = Redis.new(:host => 'localhost', :port => 6379)
  end

  get '/' do
    send_file File.expand_path 'index.html'
  end

  get '/init-game' do
    game, g_id  = TicTacToe.new, SecureRandom.uuid
    @@redis.set g_id, YAML::dump(game)
    @@redis.expire g_id, G_SESSION_EXP 
    payload = { 
      :message => MESSAGES[:game_started],
      :game_id => g_id
    }
    respond_with_json 200, payload
  end

  put '/take-turn' do
    g_id, player_mark, move = params[:game_id], params[:mark], params[:move]
    return respond_with_json(400, {:message => ERRORS[:no_move]}) if g_id.nil? or player_mark.nil? or move.nil? 
    g_session = @@redis.get g_id
    return respond_with_json(400, {:message => ERRORS[:no_game]}) if g_session.nil?
    game = YAML::load g_session
    game.take_turn!(player_mark, move.to_sym)
    payload = {}
    if game.winner?
      payload[:message] = MESSAGES[:game_won]
      payload[:winner] = game.winner
      @@redis.del g_id
    else
      dpb_mark = game.opponent_mark(player_mark)
      dpb_move = DeepBlue.pick_move(game, dpb_mark, player_mark)
      game.take_turn!(*dpb_move)
      if game.winner?
        payload[:message] = MESSAGES[:game_won]
        payload[:winner] = game.winner
        @@redis.del g_id
      else
        payload[:message] = MESSAGES[:took_turn]
      end
      payload[:opp_mark] = dpb_mark
      payload[:opp_move] = dpb_move[1]
      @@redis.set g_id, YAML::dump(game)
      @@redis.expire g_id, G_SESSION_EXP
    end
    respond_with_json 200, payload
  end

  private 
  def respond_with_json(status = 200, payload = {}, headers = {})
    headers.merge!({'Content-Type' => 'application/json'})
    [status, headers, payload.to_json]
  end
end
