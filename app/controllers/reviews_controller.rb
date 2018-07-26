class ReviewsController < ApplicationController
  before_action(:authenticate, only: [:create, :update, :destroy])

  def reviews_of_book
    if book = Book.includes(:reviews).find_by(isbn: params[:isbn])
      reviews = book.reviews().includes(:user)
      reviews_attrs = reviews.map() do |review|
        review.camelized_attributes()
          .merge({ writer: review.user().camelized_attributes_with_additional_info() })
      end
      
      render json: { results: reviews_attrs }, status: :ok
    else
      render json: { messages: ['not found'] }, status: :not_found
    end
  end

  def create
    review = Review.new(review_params())
    review.book = current_user().bookshelf().books().find_by(isbn: params[:book][:isbn])
    review.user = current_user();
    
    if review.save()
      render json: { review: review.camelized_attributes() }, status: :created
    else
      render json: { messages: review.errors().full_messages() }, status: :bad_request
    end
  end

  def update
    if !review = Review.find_by(id: params[:id], user: current_user())
      render json: { messages: ['bad request'] }, status: :bad_request
    elsif review.update(review_params())
      render json: { review: review.camelized_attributes() }, status: :ok
    else
      render json: { messages: review.errors().full_messages() }, status: :bad_request
    end
  end

  def destroy
    if !review = Review.find_by(id: params[:id], user: current_user())
      render json: { messages: ['bad request'] }, status: :bad_request
    elsif review.destroy()
      render json: {}, status: :no_content
    else
      render json: { messages: review.errors().full_messages() }, status: :bad_request
    end
  end
  
  private
    def review_params
      params.require(:review).permit(:rating, :body)
    end
end
