class StoredBooksController < ApplicationController
  before_action(:authenticate, only: [:create, :destroy])

  def create
    stored_book = StoredBook.new()
    stored_book.bookshelf = Bookshelf.find_by(id: params[:shelf_id])
    stored_book.book = Book.find_by(isbn: params[:isbn])

    if stored_book.save()
      render json: { book: stored_book.book.detail_attributes(current_user()) }, status: :created
    else
      render json: { messages: stored_book.errors().full_messages() }, status: :bad_request
    end
  end

  # ユーザーの本棚にある本とユーザーの本に対するレビューを削除する
  def destroy
    bookshelf = Bookshelf.find_by(id: params[:shelf_id])
    book = Book.find_by(isbn: params[:isbn])
    stored_book = StoredBook.find_by(bookshelf: bookshelf, book: book)
    review = Review.find_by(user: current_user(), book: book)

    if stored_book.nil?()
      render json: { messages: ['bad request'] }, status: :bad_request
    elsif stored_book.destroy() && (review ? review.destroy() : true)
      render json: {}, status: :no_content
    else
      messages = stored_book.errors().full_messages()
      messages.concat(review.errors().full_messages()) if review
      render json: { messages: messages }, status: :bad_request
    end
  end
end
