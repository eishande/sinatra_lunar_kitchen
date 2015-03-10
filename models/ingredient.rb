require 'pg'
require 'pry'

def db_connection
  begin
    connection = PG.connect(dbname: "recipes")
    yield(connection)
  ensure
    connection.close
  end
end

class Ingredient
  attr_reader :id, :name, :recipe_id

  @ingredients = []

  def initialize(id, name, recipe_id)
    @id = id
    @name = name
    @recipe_id = recipe_id
  end

  def self.all
    @ingredients
  end

  db_connection do |conn|
    $all_ingredients = conn.exec("SELECT id, name, recipe_id FROM ingredients")
    $all_ingredients = $all_ingredients.to_a
  end

  $all_ingredients.each do |row|
    @ingredients << Ingredient.new(row["id"], row["name"], row["recipe_id"])
  end

end
