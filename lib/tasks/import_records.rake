namespace :import do
  BOOKS_PATH = "#{Rails.public_path}/books/"

  def read_books
    books = []
    Dir.foreach(BOOKS_PATH) do |item|
      next if item == '.' or item == '..'
      puts "Reading #{item}...".green
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

  def book_sentences(book_contents)
    puts "SEGEMENT".green
    sentences = extract_sentences(book_contents)
    puts "CREATE MODELS".green
    sentences.reduce([]){|result, sentence_text| result << Sentence.new(content: sentence_text)}
  end

  def extract_sentences(book_contents)
    PragmaticSegmenter::Segmenter.new(text: book_contents.force_encoding('UTF-8'), doc_type: 'txt').segment
  end

  desc 'Import Book from files.'
  task books: :environment do
    puts "Start reading the books...".yellow
    books = read_books
    puts "Importing books...".yellow
    Book.import(books)
  end

  desc 'Import Book Sentences from files.'
  task sentences: :environment do
    puts "START".yellow
    file_path = "#{BOOKS_PATH}/test.txt"
    file = File.open(file_path, "rb")
    contents = file.read
    book_sentences(contents)
  end
end