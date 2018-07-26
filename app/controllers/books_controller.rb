class BooksController < ApplicationController
  before_action(:authenticate, only: [:create, :approve, :reject])
  before_action(:authorize_for_admin, only: [:approve, :reject])

  def popular
    # 人気のある（本棚に格納されている数が多い）本を取得する
    # N+1問題を回避するためにキャッシュしている
    caching_current_user = User.caching_user().find_by(id: current_user()&.id)
    popular_books_attrs = Book.popular(0, 40).map do |book|
      book.detail_attributes(caching_current_user)
    end

    render json: { books: popular_books_attrs }, status: :ok
  end
  
  def search
    if params[:q].blank?()
      render json: { books: [] }
      return
    end

    # Books on DB
    internal_books_attrs = Book.search(params[:q], params[:offset], params[:limit]).map do |book|
      book.detail_attributes(current_user())
    end

    # 検索結果がLimitに足りてない場合は後続の処理で外部APIのブックデータも取得するが、足りている場合はここで処理を終了する
    if (params[:limit] && internal_books_attrs.count() >= params[:limit].to_i())
      render json: { books: internal_books_attrs }, status: :ok
      return
    end

    # 外部APIのブックデータはLimit数に限らず、すべて（外部APIの上限値分）取得しにいく
    # Books on Google
    external_books_attrs = GoogleBook::search(params[:q])

    # 外部APIのブックデータの内、すでにローカルに保存されているブックは取り除く
    # 本の外部APIデータとローカルデータの差集合を作りたいので、同じ本かどうかを照合するために必要なメソッドを各ハッシュインスタンスにミックスインする
    # 他の方法として、外部API・ローカルデータの型を共にBookにして、Bookクラスに照合するためのメソッドをオーバーライドで定義することを考えたが、
    # Railsのデフォルト挙動への影響が読みきれないため、パフォーマンスは悪くなると思われるが各インスタンスにミックスインすることにした
    all_internal_books_attrs = Book.select(:isbn).map(&:camelized_attributes).each { |b| b.extend(BookCollater) }
    external_books_attrs.each { |b| b.extend(BookCollater) }

    render json: { books: internal_books_attrs + (external_books_attrs - all_internal_books_attrs) }, status: :ok
  end

  # request
  def create
    authors = params[:book][:authors]
    params[:book][:authors] = JSON.unparse(authors) if authors
    book = Book.new(book_params())
    book.status = :requested

    if book.save()
      render json: { book: book.detail_attributes(current_user()) }, status: :created
    else
      render json: { messages: book.errors().full_messages() }, status: :bad_request
    end
  end

  def approve
    book = Book.find_by(isbn: params[:isbn], status: :requested)

    if !book
      render json: { messages: ['approve failed'] }, status: :bad_request
    elsif book.update(status: :available)
      render json: { book: book.detail_attributes(current_user()) }, status: :ok
    else
      render json: { messages: book.errors().full_messages() }, status: :bad_request
    end
  end

  def reject
    book = Book.find_by(isbn: params[:isbn], status: :requested)
    
    if !book
      render json: { messages: ['reject failed'] }, status: :bad_request
    elsif book.destroy()
      render json: {}, status: :no_content
    else
      render json: { messages: book.errors().full_messages() }, status: :bad_request
    end
  end

  def book_of_library
    if internal_book = Book.find_by(isbn: params[:isbn])
      internal_book_attrs = internal_book.detail_attributes(current_user())
      render json: { book: internal_book_attrs }, status: :ok
    elsif external_book_attrs = GoogleBook::find_book_by_isbn(params[:isbn])
      render json: { book: external_book_attrs }, status: :ok
    else
      render json: { messages: ['not exists'] }, status: :not_found
    end
  end

  # 指定されたユーザーが所持している本をRenderする
  def book_of_someone
    book = Book.find_by(isbn: params[:isbn])
    user = User.find_by(id: params[:user_id])

    if book && user && user.has?(book)
      render json: {
        book: book.detail_attributes(current_user())
          .merge({ owner: user.camelized_attributes_with_additional_info() })
      }, status: :ok
    else
      render json: { messages: ['not found'] }, status: :not_found
    end
  end

  private def book_params()
    params.require(:book).permit(:isbn, :title, :subtitle, :authors, :publisher, :published_date, :description, :page_count, :thumbnail_url)
  end
end
