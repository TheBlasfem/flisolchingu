require 'chingu'
include Gosu

class Game < Chingu::Window
  def initialize
    super(800, 600)
    self.caption = "Mi primer juego con Chingu"
    self.input = {:escape => :exit}
    switch_game_state(Play)
  end	 
end

class Play < Chingu::GameState
  trait :timer
  def initialize
    super
    self.input = {:p => Pause}
    @score = 0
    @score_text = Chingu::Text.create(:x=>10, :y=>10, :text=> "Score: #{@score}")
    @player = Player.create(:x => 320, :y => 240, :image => Image["Starfighter.bmp"])
    every(1500) { Moneda.create} if Moneda.all.size < 30
  end
  def update
    super
    @player.each_collision(Moneda) do |nave, moneda|
      moneda.destroy
      @score += 10
      @score_text.text = "Score: #{@score}"
    end
  end
end

class Pause < Chingu::GameState
  def initialize
    super
    self.input = {:p => :un_pause}
    @title = Chingu::Text.create(:text=> "PAUSA, aprieta p nuevamente para seguir jugando", :x=> 100, :y=> 200, :size=> 20)
  end
  def un_pause; pop_game_state; end
  def draw
    super
    previous_game_state.draw
  end
end

class Player < Chingu::GameObject
  traits :velocity, :effect, :collision_detection, :bounding_circle
  def initialize(options={})
    super
    self.input = [:holding_left, :holding_right, :holding_up]
  end
  def holding_left; rotate(-4.5); end
  def holding_right; rotate(4.5); end
  def holding_up
    self.velocity_x = Gosu::offset_x(self.angle,3)
    self.velocity_y = Gosu::offset_y(self.angle,3)
  end
  def update
    @x %= $window.width
    @y %= $window.height
    self.velocity_x *= 0.95
    self.velocity_y *= 0.95
  end
end

class Moneda < Chingu::GameObject
  traits :collision_detection, :bounding_circle
  def initialize(options={})
    super
    @image = Image["coin.png"]
    @x = rand($window.width)
    @y = rand($window.height) 
  end
end

Game.new.show
