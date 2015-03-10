class Recipe
  attr_reader :id, :name, :instructions, :description, :ingredients
  @recipes = []

  def initialize (id, name, instructions, description)
    @id = id
    @name = name
    @instructions = instructions
    @description = description

    @ingredients = self.db_connection do |conn|
      Ingredient.all.select { |row| row.recipe_id == @id }
    end.to_a
  end

  def ingredients
    @ingredients
  end

  def self.all
    @recipes
  end

  def self.find(id)
    @recipes.each do |row|
      return row if row.id == id
    end
    Recipe.new(id, "Error", "This recipe doesn't have any instructions.", "This recipe doesn't have a description.")
  end

  def self.db_connection
    begin
      connection = PG.connect(dbname: "recipes")
      yield(connection)
    ensure
      connection.close
    end
  end

  all_recipes = self.db_connection do |conn|
    all_recipes = conn.exec("SELECT id, name, instructions, description FROM recipes")
  end.to_a

  all_recipes.each do |row|
    @recipes << Recipe.new(row["id"], row["name"], row["instructions"], row["description"])
  end

end
