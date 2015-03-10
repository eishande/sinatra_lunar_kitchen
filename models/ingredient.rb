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

  def self.db_connection
    begin
      connection = PG.connect(dbname: "recipes")
      yield(connection)
    ensure
      connection.close
    end
  end

  all_ingredients = self.db_connection do |conn|
    conn.exec("SELECT id, name, recipe_id FROM ingredients")
  end.to_a

  all_ingredients.each do |row|
    @ingredients << Ingredient.new(row["id"], row["name"], row["recipe_id"])
  end

end
