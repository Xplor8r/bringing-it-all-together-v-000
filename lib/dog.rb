class Dog
  attr_accessor :id, :name, :breed
  
  def initialize(hash)
    hash.each { |key, value| self.send("#{key}=", value) }
  end
  
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL

    DB[:conn].execute(sql).map { |row| self.new_from_db(row) }
  end
  
  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    
    DB[:conn].execute(sql)
  end
  
def save
  if self.id
    self.update
  else
    sql = <<-SQL
      INSERT INTO dogs (name, breed) 
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
  end
  
  def self.create(name, breed)
    dog = self.new(name, breed)
    dog.save
    dog
  end
  
  def self.find_by_name(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL
    
    DB[:conn].execute(sql, id).map { |row| self.new_from_db(row) }.first
  end
  
  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_data = song[0]
      dog = self.new(dog_data[0], dog_data[1], dog_data[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end
  
  def self.new_from_db(row)
    id, name, breed = row[0], row[1], row[2]
    self.new(id, name, breed)
  end
  
  
end