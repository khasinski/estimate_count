# frozen_string_literal: true
require "active_record"

class MySQLTable < ActiveRecord::Base
end

class PostgreSQLTable < ActiveRecord::Base
end

def load_database(name)
  case name
  when "postgresql"
    connect_postgresql!
  when "mysql"
    connect_mysql!
  else
    raise "Unsupported database"
  end
end

def connect_postgresql!
  ActiveRecord::Base.establish_connection(
    adapter: "postgresql",
    database: "test",
    username: "test",
    password: "test",
    host: "localhost",
    port: 5432,
  )

  ActiveRecord::Schema.define do
    create_table :postgre_sql_tables, force: true do |t|
      t.integer :level
    end
  end
end

def connect_mysql!
  ActiveRecord::Base.establish_connection(
    adapter: "mysql2",
    prepared_statements: true,
    encoding: "utf8mb4",
    charset: "utf8mb4",
    collation: "utf8mb4_unicode_ci",
    timeout: 5000,
    database: "test",
    username: "test",
    password: "test",
    host: "127.0.0.1",
    port: 3306,
  )

  ActiveRecord::Schema.define do
    create_table :my_sql_tables, force: true do |t|
      t.integer :level
    end
  end
end


