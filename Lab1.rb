require 'csv'

class Inventory
    def initialize
        @books_array = []
        @title = ''
        @author = ''
        @isbn = ''
    end

    def list_books
        CSV.foreach('books.csv', headers: true, col_sep: ',') do |row|
            @title = row['title']
            @author = row['author']
            @isbn = row['isbn']
            puts "Title: #{@title} | Author: #{@author} | ISBN: #{@isbn}"
        end
    end

    def get_book_info
        puts 'Name of book:'
        @title = gets.chomp
        puts 'Author of the book:'
        @author = gets.chomp
        puts 'ISBN of the book:'
        @isbn = gets.chomp
    end

    def add_new_book
        get_book_info
        CSV.open('books.csv', 'a') do |csv|
            csv << [@title, @author, @isbn]
        end
    end

    def remove_book_by_isbn
        puts 'Enter ISBN of the book to remove:'
        isbn = gets.chomp
        csv_data = CSV.read('books.csv', headers: true)
        new_data = csv_data.delete_if { |row| row['isbn'] == isbn }
        CSV.open('books.csv', 'w') do |csv|
            csv << csv_data.headers 
            new_data.each { |row| csv << row }
        end
    end
end

inventory = Inventory.new()

answer = ''
while answer != '4'
    puts 'Select Options:'
    puts '1- List books'
    puts '2- Add new book'
    puts '3- Remove book by ISBN'
    puts '4- Exit'
    answer = gets.chomp
  
    case answer
    when '1'
      inventory.list_books
    when '2'
      inventory.add_new_book
    when '3'
      inventory.remove_book_by_isbn
    when '4'
      break
    else
      puts 'Invalid option!'
    end
end
