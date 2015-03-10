#same comments as those I made in ingredients about require and db_connection
require 'pg'
require_relative 'ingredient'

def db_connection
  begin
    connection = PG.connect(dbname: "recipes")
    yield(connection)
  ensure
    connection.close
  end
end

class Recipe
  attr_reader :id, :name, :instructions, :description, :ingredients
  @recipes = []

  def initialize (id, name, instructions, description)
    @id = id
    @name = name
    @instructions = instructions
    @description = description

#rewrite this without using global variables ($variable)
    db_connection do |conn|
      $ingredients_list = Ingredient.all.select { |row| row.recipe_id == @id }
    end

    @ingredients = $ingredients_list.to_a
  end

  def ingredients
    @ingredients
  end

  def self.all
    @recipes
  end

  #ruby returns the last line that's run, so you technically don't need to specify return here.

  def self.find(id)
    @recipes.each do |row|
      return row if row.id == id
    end
    return Recipe.new(id, "Error", "This recipe doesn't have any instructions.", "This recipe doesn't have a description.")
  end

#rewrite this without global variables ($variable). see the modification I made in the ingredient class to model on.
  db_connection do |conn|
    $all_recipes = conn.exec("SELECT id, name, instructions, description FROM recipes")
    $all_recipes = $all_recipes.to_a
  end

  $all_recipes.each do |row|
    @recipes << Recipe.new(row["id"], row["name"], row["instructions"], row["description"])
  end

end
