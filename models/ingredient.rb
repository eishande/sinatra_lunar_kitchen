#remove these from your classes. since you require your classes elsewhere, you can place your requires in one place rather than within the model
require 'pg'
require 'pry'

#can you think of a place that would be better suited for this db_connection to be in? Think about class methods and how classes are defined. A class file should have everything contained within the class rather than have methods outside of the class.
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

  all_ingredients = db_connection do |conn|
    conn.exec("SELECT id, name, recipe_id FROM ingredients")
  end.to_a

  all_ingredients.each do |row|
    @ingredients << Ingredient.new(row["id"], row["name"], row["recipe_id"])
  end

end
