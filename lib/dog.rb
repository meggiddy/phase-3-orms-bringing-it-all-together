require 'sqlite3'

class Dog
  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def save
    if self.id
      self.update
    else
      DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", self.name, self.breed)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.create(name:, breed:)
    dog = self.new(name: name, breed: breed)
    dog.save
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.all
    DB[:conn].execute("SELECT * FROM dogs").map do |row|
      self.new_from_db(row)
    end
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"
    row = DB[:conn].execute(sql, name).flatten
    self.new_from_db(row)
  end

  def self.find(id)
    sql = "SELECT * FROM dogs WHERE id = ? LIMIT 1"
    row = DB[:conn].execute(sql, id).flatten
    self.new_from_db(row)
  end
end
