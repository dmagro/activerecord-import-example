namespace :import do
  BOOKS_PATH = "#{Rails.public_path}/books/"

  def read_books
    books = []
    Dir.foreach(BOOKS_PATH) do |item|
      next if item == '.' or item == '..'
      puts item
      books << read_book(item)
    end
    books
  end

  def read_book(file_name)
    file_path = "#{BOOKS_PATH}/#{file_name}"
    file = File.open(file_path, "rb")
    contents = file.read
    book_details = book_details(contents)
    Book.new(book_details)
  end

  def book_details(book_contents)
    {
      title: /Title:(.+)/.match(book_contents)[1].strip,
      author: /Author:(.+)/.match(book_contents)[1].strip,
      language: /Language:(.+)/.match(book_contents)[1].strip 
    }
  end

  desc 'Import Book from files.'
  task books: :environment do
    books = read_books
    Book.import(books)
  end

  desc 'Import Book Sentences from files.'
  task sentence: :environment do
    
  end
end