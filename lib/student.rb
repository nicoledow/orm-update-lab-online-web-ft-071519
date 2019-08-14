require_relative "../config/environment.rb"
require "pry"

class Student
  attr_accessor :name, :grade
  attr_reader :id
  

  def initialize(id=nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end
  
  
  def self.new_from_db(row)
    new_id = row[0]
    new_name = row[1]
    new_grade = row[2]
    new_student = self.new(new_id, new_name, new_grade)
    new_student
  end
  
  
  def self.create_table
    sql = <<-SQL
          CREATE TABLE IF NOT EXISTS students(
          id INTEGER PRIMARY KEY,
          name TEXT,
          grade TEXT)
          SQL
          
    DB[:conn].execute(sql)
  end
  
  
  def self.drop_table
    sql = "DROP TABLE students"
    DB[:conn].execute(sql)
  end
  
  
  def save
    if self.id
      self.update
    else
      sql = <<-SQL
            INSERT INTO students (name, grade)
            VALUES (?, ?)
            SQL
          
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end
  
  
  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end
  
  
  def self.create(id=nil, name, grade)
    student = self.new(id, name, grade)
    student.save
  end
  
  
  def self.find_by_name(name)
    sql = <<-SQL
          SELECT *
          FROM students
          WHERE name = ?
          SQL
          
    row = DB[:conn].execute(sql, name)
    found_id = row[0][0]
    found_name = row[0][1]
    found_grade = row[0][2]
    self.new(found_id, found_name, found_grade)
    
  end


end
