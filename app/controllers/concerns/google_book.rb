require 'net/https'

class GoogleBook
  
  class << self

    def search(q)
      return [] if q.blank?()

      response = request_to_google_books_api(q)
      parse_response(response)
    end

    private def request_to_google_books_api(q)
      encoded_query = URI.encode_www_form({ q: q.strip(), maxResults: 40 })
      url = URI.parse("https://www.googleapis.com/books/v1/volumes?#{encoded_query}")
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      request = Net::HTTP::Get.new(url.request_uri)
    
      http.request(request)
    end

    private def parse_response(response)
      parsed = JSON.parse(response.body).with_indifferent_access()
  
      return [] if !parsed[:totalItems] || parsed[:totalItems].zero?()
      
      books = parsed[:items].map do |item|
        vi = item[:volumeInfo]
        isbn_13 = vi[:industryIdentifiers]&.find() { |industry_identifier| industry_identifier[:type] == 'ISBN_13' }
  
        {
          isbn: isbn_13 ? isbn_13[:identifier] : nil,
          title: vi[:title],
          subtitle: vi[:subtitle],
          authors: vi[:authors],
          publisher: vi[:publisher],
          publishedDate: vi[:publishedDate],
          description: vi[:description],
          pageCount: vi[:pageCount],
          thumbnailUrl: vi.dig(:imageLinks, :thumbnail),
          status: Book.statuses[:unavailable]
        }.with_indifferent_access()
      end
  
      # 13桁のISBNとタイトルのいずれかがないデータは当APIでは扱わないこととする
      books.select { |book| !(book[:isbn].nil?() || book[:title].nil?()) }
    end

    def find_book_by_isbn(isbn)
      # 存在する正しいISBNを指定してもデータが取得できない場合がある
      # q=#{isbn_13}+isbn:#{isbn_13}のようにすると取れるようになったデータを確認することができた（これでもダメな場合があるかどうかは未確認）
      books = GoogleBook::search("#{isbn}+isbn:#{isbn}")
      books.select() { |book| book[:isbn] == isbn }[0]
    end
  end
   
end