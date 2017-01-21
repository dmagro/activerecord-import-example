require "benchmark"

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
    book_text = file.read
    Book.new(book_contents(book_text))
  end

  def book_contents(book_text)
    book_details = book_details(book_text)
    book_details.merge({ sentences: book_sentences(book_text) })
  end

  def book_details(book_contents)
    {
      title: /Title:(.+)/.match(book_contents)[1].strip,
      author: /Author:(.+)/.match(book_contents)[1].strip,
      language: /Language:(.+)/.match(book_contents)[1].strip 
    }
  end

  def book_sentences(book_contents)
    puts "Extract Sentences text".yellow
    sentences = extract_sentences(book_contents)
    puts "Create Sentences".yellow
    sentences.reduce([]){|result, sentence_text| result << Sentence.new(content: sentence_text)}
  end

  def extract_sentences(book_contents)
    PragmaticSegmenter::Segmenter.new(text: book_contents.force_encoding('UTF-8'), doc_type: 'txt').segment
  end

  desc 'Import Book from files.'
  task books: :environment do
    time = Benchmark.measure do
      puts "Start reading the books...".green
      books = read_books
      puts "Importing books...".yellow
      books.each{ |book| book.save }
    end
    puts "Time: ".green
    puts time
  end

  desc 'Import Book from files with ActiceRecord Import.'
  task books_faster: :environment do
    time = Benchmark.measure do
      puts "Start reading the books...".green
      books = read_books
      puts "Importing books...".yellow
      Book.import(books)
    end
    puts "Time: ".green
    puts time
  end
end