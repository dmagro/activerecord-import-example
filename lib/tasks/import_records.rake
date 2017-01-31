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
    sentences_records = sentences.reduce([]){|result, sentence_text| result << Sentence.new(content: sentence_text)}
    puts "Extracted #{sentences_records.count} sentences"
    sentences_records
  end

  def extract_sentences(book_contents)
    PragmaticSegmenter::Segmenter.new(text: book_contents.force_encoding('UTF-8'), doc_type: 'txt').segment
  end

  desc 'Import Book from files.'
  task books: :environment do
    time = Benchmark.bmbm do |x|
      books = []
      x.report("Extract Books:"){ books = read_books }
      x.report("Regular Import:"){ books.each{ |book| book.save } }
      x.report("Delete Records:"){Sentence.destroy_all; Book.destroy_all}
      x.report("ActiveRecord Import:"){ Book.import(books, recursive: true) }
    end
    puts "Time: ".green
    puts time
  end
end