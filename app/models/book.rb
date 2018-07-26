# ブックモデルのクラス
class Book < ApplicationRecord
  include ModelHelper
  
  enum status: { unavailable: 0, requested: 1, available: 2 }
  
  # attr_accessor :owner

  # Association
  has_many(:stored_books, dependent: :destroy)
  has_many(:bookshelves, through: :stored_books)
  has_many(:reviews, dependent: :destroy)
  has_many(:users, through: :reviews)

  # Validation
  # このAPIではISBN13しか扱わない
  # ISBN13の場合、数字だけになるはず（ISBN10の場合はチェックディジットにXが入ることもある）
  validates(:isbn, presence: true, uniqueness: true, format: { with: /\A[\d]{13}\z/ })
  validates(:title, presence: true)
  validate(:validate_authors)

  # 本棚に格納されている数が多い本から順に取得するスコープ
  scope(:popular, ->(offset, limit) { 
    where(status: :available).left_joins(:stored_books).group(:id)
      .order('COUNT(stored_books.id) DESC').limit(limit).offset(offset)
      .includes(:stored_books)
  })

  class << self

    def search(q, offset, limit)
      return [] if q.blank?()

      # ステータスがavailable、requestedの順にソートし、availableにおいては本棚に格納されている数が多い順でソートする
      Book.where(build_complex_condition_for_full_text_search(q))
        .left_joins(:stored_books)
        .group(:id)
        .order('books.status DESC, COUNT(stored_books.id) DESC, books.title')
        .limit(limit&.to_i())
        .offset(offset&.to_i())
        .includes(:stored_books)
    end

    # 全文検索のための複雑な条件を構築する
    # プレースホルダーを含んだ条件テンプレートとプレースホルダーの対応値を一緒に返す
    # ex.) ['isbn IN (:full_0, :full_1) OR title LIKE :partial_0 OR title LIKE :partial_1 OR subtitle LIKE :partial_0 OR...', { full_0: v0, full_1: v1, partial_0: "%#{v0}%", partial_1: "%#{v1}%" }]
    private def build_complex_condition_for_full_text_search(q)
      # スペース（全角含む）で単語を区切る
      words = q.strip().split(/[\s　]+/).uniq()

      # プレースホルダーの対応値を作成する
      corresponding_values = {}
      words.each_with_index() do |word, index|
        i = index.to_s()
        corresponding_values[('full_' + i).to_sym()] = word
        corresponding_values[('partial_' + i).to_sym()] = "%#{word}%"
      end
      
      # 対応値を完全一致用と部分一致用に分ける
      partitioned_corresponding_keys = corresponding_values.keys().partition() { |k| /full_\d+/ =~ k }
      conditions_will_concat_by_or = []

      # ISBNは完全一致で検索
      isbn_condition = 'isbn IN (' + partitioned_corresponding_keys[0].map() { |k| ":#{k}" }.join(', ') + ')'
      conditions_will_concat_by_or.push(isbn_condition)

      # タイトルなどの他のカラムは部分一致で検索
      [:title, :subtitle, :authors, :publisher, :description].each() do |column|
        partitioned_corresponding_keys[1].each() do |partial_i|
          conditions_will_concat_by_or.push("#{column} LIKE :#{partial_i}")
        end
      end

      [conditions_will_concat_by_or.join(' OR '), corresponding_values]
    end
  end

  # 
  def formatted_attributes
    camelized_attrs = self.camelized_attributes()

    authors_str = self.authors
    camelized_attrs[:authors] = JSON.parse(authors_str) unless authors_str.nil?()
    
    camelized_attrs.merge({
      # そのままでは文字列になるため、整数値に変換する
      status: self.read_attribute_before_type_cast(:status)
    })
  end

  def detail_attributes(current_user)
    self.formatted_attributes().merge({
      isOwnedByCurrentUser: current_user ? current_user.has?(self) : false,
      storedCount: self.stored_books().size()
    })
  end

  private
    # 著者の値はJSON.parse()で配列に変換できる文字列でないとならない
    def validate_authors
      return if self.authors.nil?()

      message = 'is invalid format'
      parsed_authors =
        begin
          # authorsにはGoogleBooksAPIで取得した値がそのまま格納されているはずなので、JSON.parseは必ず成功するはず
          JSON.parse(self.authors)
        rescue JSON::ParserError => e
          self.errors[:authors] << message
          return
        end

      self.errors[:authors] << message unless parsed_authors.instance_of?(Array)
    end
end
