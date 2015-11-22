require 'gosu'
require_relative 'box'
require_relative 'circle'
require 'pry'

class GameWindow < Gosu::Window
  attr_accessor :width, :height

  def initialize(width = 640, height = 480)
    @width = width
    @height = height
    super @width, @height
    self.caption = "Gosu Asteroids"
    ship_radius = 10
    @circle = Circle.new(ship_radius, width, height, Gosu::Color::RED, width/2, height/2, 0.0, 270.0)
    @ship_head = Circle.new(ship_radius/2, width, height, Gosu::Color::GREEN, width/2 + ship_radius/2, height/2 + ship_radius/2, 0.0, 270.0)
    @img_circle = Gosu::Image.new(self, @circle, false)
    @img_ship_head = Gosu::Image.new(self, @ship_head, false)
    @enemy_circles = []
    @enemy_img_circles = []
    @bullets = []
    @bullet_imgs = []
    10.times do
      circle = Circle.new(12, width, height, Gosu::Color::WHITE)
      circle.randomize_location(width, height)
      @enemy_circles << circle
      @enemy_img_circles << Gosu::Image.new(self, circle, false)
    end
  end

  def update
    speed_step = 0.0
    angle_step = 0.0
    if Gosu::button_down? Gosu::KbLeft
      angle_step = -2.0
    elsif Gosu::button_down? Gosu::KbRight
      angle_step = 2.0
    elsif Gosu::button_down? Gosu::KbUp
      speed_step = 0.25
    elsif Gosu::button_down? Gosu::KbDown
      speed_step = -0.25
    elsif Gosu::button_down? Gosu::KbSpace
      bullet_radius = 2
      bullet = Bullet.new(bullet_radius, width, height, Gosu::Color::BLUE, @circle.x + @ship_head.radius + bullet_radius, @circle.y + @ship_head.radius + bullet_radius, @circle.speed + 2.0, @circle.angle)
      @bullets << bullet
      @bullet_imgs << Gosu::Image.new(self, bullet, false)
    end
    @bullets.each do |bullet|
      bullet.move
      bullet = nil if !bullet.onscreen?(width, height)
    end
    @circle.move(angle_step, speed_step, width, height)
    @ship_head.move(angle_step, speed_step, width, height)
    asteroid_hit?
    close if collision?
  end

  def draw
    @bullet_imgs.each_with_index do |image, i|
      image.draw @bullets[i].x, @bullets[i].y, 0, 1, 1, @bullets[i].color, :default
    end
    @img_circle.draw @circle.x,@circle.y, 0, 1, 1, @circle.color,:default
    @img_ship_head.draw @ship_head.x + (@circle.radius)*Math.cos(@circle.angle*Math::PI/180.0).round(2), @ship_head.y + (@circle.radius)*Math.sin(@circle.angle*Math::PI/180).round(2), 0, 1, 1, @ship_head.color,:default
    @enemy_img_circles.each_with_index do |circle, i|
      circle.draw @enemy_circles[i].x, @enemy_circles[i].y, 0, 1, 1, @enemy_circles[i].color, :default
    end
  end

  def collision?
    collision = false
    @enemy_circles.each do |enemy|
      dx = (@circle.x - enemy.x)**2
      dy = (@circle.y - enemy.y)**2
      distance = Math.sqrt(dx+dy)
      if (distance < (@circle.radius + enemy.radius))
        collision = true
      end
      break if collision
    end
    collision
  end

  def asteroid_hit?
    hit = false
    @enemy_circles.each_with_index do |enemy, i|
      @bullets.each do |bullet|
        dx = (bullet.x - enemy.x)**2
        dy = (bullet.y - enemy.y)**2
        distance = Math.sqrt(dx + dy)
        if (distance < (bullet.radius + enemy.radius))
          hit = true
          @enemy_circles.delete_at(i)
          @enemy_img_circles.delete_at(i)
        end
      end
    end
    hit
  end

end

window = GameWindow.new
window.show
