class Dog
  attr_accessor :name, :breed
  attr_reader :id

 def initialize(breed:, name:, id:nil)
    @name = name
    @breed = breed
    @id = id
  end

 def self.create_table
    sql=<<-SQL
    CREATE TABLE IF NOT EXISTS dogs(
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL

   DB[:conn].execute(sql)
  end

 def self.drop_table
    sql=<<-SQL
    DROP TABLE IF EXISTS dogs
    SQL

   DB[:conn].execute(sql)
  end

 def self.new_from_db(row)
    hash={
      id: row[0],
      name: row[1],
      breed: row[2]
    }
    self.new(hash)
  end

 def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ?
    SQL

   row = DB[:conn].execute(sql, name)
    new_from_db(row.first)
  end

 def update
    sql=<<-SQL
    UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL

   DB[:conn].execute(sql, self.name, self.breed, self.id)

 end


 def save
    if self.id
      self.update
    else
      sql=<<-SQL
      INSERT INTO dogs (name, breed) VALUES (?, ?)
      SQL

     DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end

 def self.create(hash)
    dog = self.new(hash)
    dog.save
    dog
  end

 def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs WHERE id = ?
    SQL

   row = DB[:conn].execute(sql, id)
    new_from_db(row.first)
  end

 def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed).flatten

   if !dog.empty?
      new_from_db(dog)
    else
      create(name: name, breed: breed)
    end
  end

end
