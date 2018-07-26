class BookshelvesController < ApplicationController

  # ソートなどが未実装
  def popular
    popular_shelves_attrs = Bookshelf.includes(:books, :user).map() do |shelf|
      shelf.camelized_attributes().merge({
        booksCount: shelf.books().count(),
        owner: shelf.user().camelized_attributes_with_additional_info()
      })
    end
    
    render json: { results: popular_shelves_attrs }, status: :ok
  end

  # 検索ロジックは未実装
  def search
    if params[:q].blank?()
      render json: { results: [] }
      return
    end

    q = params[:q].strip()
    bookshelves = Bookshelf.includes(:books, :user)

    bookshelves_attrs = bookshelves.map do |shelf|
      shelf.camelized_attributes().merge({
        booksCount: shelf.books().count(),
        owner: shelf.user().camelized_attributes_with_additional_info()
        # followingCount:
        # followersCount:
      })
    end

    render json: { results: bookshelves_attrs }, status: :ok
  end

  def show
    if bookshelf = Bookshelf.includes(:books, :user).find_by(id: params[:id])
      render json: { 
        books: bookshelf.books().map(&:camelized_attributes),
        booksCount: bookshelf.books().count(),
        owner: bookshelf.user().camelized_attributes_with_additional_info()
      }, status: :ok
    else
      render json: { messages: ['not found'] }, status: :not_found
    end
  end
end
