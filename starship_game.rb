require 'chingu'
include Gosu
include Chingu

class Game < Chingu::Window
  def initialize
    super(800,600)
    self.input = {:escape => :exit}
    self.caption = "Mi primer juego con Ruby!"
    switch_game_state(Play)
  end
end

class Play < Chingu::GameState
  trait :timer
  def initialize
    super
    self.input = {:p => Pause}
    @player = Player.create(:x => 320, 
    :y => 240, :image => Image["Starfighter.bmp"])
    @score = 0
    @score_text = Text.create("Score: #{@score}", :x => 10,
    :y => 10, :size => 20)
    every(1500) { Moneda.create if Moneda.all.size<30 }
  end
  def update
    super
    @player.each_collision(Moneda) do |player, moneda|
      moneda.destroy
      @score += 10
    end
     @score_text.text = "Score #{@score}"
  end
end

class Pause < Chingu::GameState
  def initialize()
    super
    @title = Chingu::Text.create(:text=>"PAUSA (aprieta 'p' nuevamente para seguir con el juego)", :x=>100, :y=>200, :size=>20, :color => Color.new(0xFF00FF00))
    self.input = { :p => :un_pause }
  end
  def draw
    super
    previous_game_state.draw
  end
  def un_pause
    pop_game_state(:setup => false)
  end
end

class Player < Chingu::GameObject
  traits :velocity, :effect, :collision_detection, :bounding_circle
  def initialize(options)
    super
    self.input = [:holding_left, :holding_right, :holding_up]
    self.max_velocity = 10
  end

  def holding_left; rotate(-4.5); end

  def holding_right; rotate(4.5); end

  def holding_up
    self.velocity_x = Gosu::offset_x(self.angle, 0.5)*self.max_velocity_x
    self.velocity_y = Gosu::offset_y(self.angle, 0.5)*self.max_velocity_y
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
    self.x = rand($window.width)
    self.y = rand($window.height)
  end
end

Game.new.show










