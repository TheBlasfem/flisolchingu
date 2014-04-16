require 'chingu'
include Gosu
include Chingu

class Game < Chingu::Window
  def initialize
    super(500, 600, false)
  end

  def setup
    self.factor = 3
    switch_game_state(Example19)
  end
end

class Example19 < Chingu::GameState
  trait :viewport
  def initialize
    super
    self.input = { :escape => :exit, :e => :edit}
    self.viewport.lag = 0
    self.viewport.game_area = [0,0,1000,1000]
    load_game_objects
    @droid = Droid.create(:x => 100,:y => 100)
  end

  def edit
    push_game_state(GameStates::Edit)
  end

  def update
    super
    @droid.each_collision(Star) do |droid, star| 
      star.destroy
      Sound["laser.wav"].play(0.5)
    end

    Bullet.each_collision(StoneWall) do |bullet, stonewall|
      bullet.die!
      stonewall.destroy
    end

    game_objects.destroy_if { |game_object| self.viewport.outside_game_area?(game_object) }

   self.viewport.center_around(@droid)

  end
end

class Droid < Chingu::GameObject
  traits :collision_detection, :bounding_box, :timer
  attr_accessor :last_x, :last_y, :direction
  def setup
    self.input = [:holding_left, :holding_right, :holding_up, :holding_down, :space]    
    @animations = Chingu::Animation.new(:file => "droid_11x15.bmp")
    @animations.frame_names = {:scan => 0..5, :up => 6..7, :down => 8..9, :left => 10..11, :right => 12..13}
    @animation = @animations[:scan]
    @speed = 3
    @last_x, @last_y = @x, @y
  end

  def holding_left
    move(-@speed,0)
    @animation = @animations[:left]
  end

  def holding_right
    move(@speed, 0)
    @animation = @animations[:right]	
  end

  def holding_up
    move(0,-@speed)
    @animation = @animations[:up]
  end

  def holding_down
    move(0,@speed)
    @animation = @animations[:down]	
  end

  def space
    Bullet.create(:x => self.x, :y => self.y, :velocity => @direction)
  end

  def move(x, y)
    @x += x
    @y += y
  end	

  def update
    @image = @animation.next
    if self.parent.viewport.outside_game_area?(self) || self.first_collision(StoneWall)
      @x = @last_x
      @y = @last_y
    end
    if @x == @last_x && @y == @last_y
      @animation = @animations[:scan]
      else
        @direction = [@x - @last_x, @y - @last_y]
    end
    @last_x, @last_y = @x, @y
  end
end

class Star < Chingu::GameObject
  traits :collision_detection, :bounding_circle

  def setup
    @animation = Chingu::Animation.new(:file => "Star.png", :size => 25)
    @image = @animation.next
    self.color = Gosu::Color.new(0xff000000)
    self.color.red = rand(255)
    self.color.green = rand(255)
    self.color.blue = rand(255)
    self.factor = 1
    cache_bounding_circle
  end

  def update
    @image = @animation.next
  end
end

class StoneWall < Chingu::GameObject
  traits :collision_detection, :bounding_box 
  def initialize(options)
    super
    @image = Image["stone_wall.bmp"]
    self.width = 50
    self.height = 50
  end
end

class Bullet < Chingu::GameObject
  traits :collision_detection, :bounding_circle, :velocity, :timer
  def setup
    self.factor = 1
    @image = Image["fire_bullet.png"]
  end

  def die!
    self.velocity = [0,0]
    between(0,50){self.factor += 0.3}.then{destroy}
  end
end


Game.new.show
