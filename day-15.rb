#!/usr/bin/env ruby
# http://adventofcode.com/day/15

input = STDIN.read

class Ingredient
  attr_reader :name, :capacity, :durability, :flavor, :texture, :calories

  def initialize(name, capacity, durability, flavor, texture, calories)
    @name = name
    @capacity = capacity
    @durability = durability
    @flavor = flavor
    @texture = texture
    @calories = calories
  end

  def to_s
    "#{@name}: C#{@capacity}, D#{@durability}, F#{@flavor}, T#{@texture}, C#{@calories}"
  end

  def self.parse(s)
    re = /(\w+): capacity (-?\d+), durability (-?\d+), flavor (-?\d+), texture (-?\d+), calories (-?\d+)/
    captures = re.match(s).captures

    new(
      captures[0],
      *captures[1..-1].map(&:to_i)
    )
  end
end

class Recipe
  # +ingredients_to_teaspoons+ should look like { Ingredient => 2, Ingredient => 98 }
  def initialize(ingredients_to_teaspoons)
    @ingredients_to_teaspoons = ingredients_to_teaspoons
  end

  def total_score
    total_capacity * total_durability * total_flavor * total_texture
  end

  def to_s
    @ingredients_to_teaspoons.map { |i, t| "#{t} #{i.name}" }.join(', ')
  end

  def score_details
    "#{to_s.ljust(36)} #{total_score.to_s.rjust(10)} = " \
    "C#{total_capacity} D#{total_durability} F#{total_flavor} T#{total_texture}"
  end

  def total_capacity; sum_property(:capacity); end
  def total_durability; sum_property(:durability); end
  def total_flavor; sum_property(:flavor); end
  def total_texture; sum_property(:texture); end
  def total_calories; sum_property(:calories); end
  private

  def sum_property(prop)
    sum = @ingredients_to_teaspoons.map { |i, t| i.send(prop) * t }.reduce(0, :+)
    [0, sum].max
  end
end

ingredients = input.split("\n").map { |s| Ingredient.parse(s) }
num_ingredients = ingredients.length

# Brute force? Brute force.
def all_combinations(ingredients, total_to_allocate = 100)
  first_ingredient = ingredients.first
  remaining_ingredients = ingredients[1..-1]

  if remaining_ingredients.any?
    (0..total_to_allocate).flat_map do |tbsp|
      all_combinations(
        remaining_ingredients,
        total_to_allocate - tbsp
      ).flat_map do |rmc|
        rmc.merge({ first_ingredient => tbsp })
      end
    end
  else
    [{ first_ingredient => total_to_allocate }]
  end
end

recipes = all_combinations(ingredients).map { |c| Recipe.new(c) }
puts "Part 1: #{recipes.map(&:total_score).max}"

diet_recipes = recipes.find_all { |r| r.total_calories == 500 }
puts "Part 2: #{diet_recipes.map(&:total_score).max}"
