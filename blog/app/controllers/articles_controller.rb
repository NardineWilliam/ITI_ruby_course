class ArticlesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_article, only: [:show, :edit, :update, :destroy, :report]
  before_action :authorize_user!, only: [:edit, :update, :destroy]

  def index
    @articles = user_signed_in? ? Article.all : Article.where(status: 'public')
  end

  def show
    unless @article.public? || (user_signed_in? && @article.user == current_user)
      redirect_to articles_path, alert: "You are not authorized to view this article."
    end
  end

  def new
    @article = current_user.articles.build
  end

  def create
    @article = current_user.articles.build(article_params)

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @article.update(article_params)
      redirect_to @article
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @article.destroy
    redirect_to root_path, status: :see_other
  end

  def report
    @article.report!
    redirect_to @article, notice: 'Article has been reported.'
  end

  private

  def set_article
    @article = Article.find(params[:id])
  end

  def authorize_user!
    redirect_to articles_path, alert: "You are not authorized to perform this action." unless @article.user == current_user
  end

  def article_params
    params.require(:article).permit(:title, :body, :status, :image)
  end
end