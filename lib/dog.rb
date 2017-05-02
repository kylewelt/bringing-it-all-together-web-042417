class Dog

  attr_accessor :name, :breed, :id

  def initialize(dog)
    @name = dog[:name]
    @breed = dog[:breed]
    @id = dog[:id]
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def save
    dog = Dog.new({name: self.name, breed: self.breed})
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    dog.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

    dog
  end

  def self.create(attributes)
    Dog.new(attributes).save
  end

  def self.find_by_id(id_num)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL

    result = DB[:conn].execute(sql, id_num).flatten
    Dog.new({name: result[1], breed: result[2], id: result[0]})
  end

  def self.find_or_create_by(dog)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
      AND breed = ?
    SQL

    result = DB[:conn].execute(sql, dog[:name], dog[:breed]).flatten

    if !result.empty?
      Dog.new({name: result[1], breed: result[2], id: result[0]})
    else
      self.create(dog)
    end
  end

  def self.new_from_db(row)
    Dog.new({name: row[1], breed: row[2], id: row[0]})
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL

    result = DB[:conn].execute(sql, name).flatten
    Dog.new({name: result[1], breed: result[2], id: result[0]})
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
