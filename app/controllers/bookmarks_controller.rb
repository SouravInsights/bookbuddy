class BookmarksController < ApplicationController
  before_action :set_bookmark, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show]
  
  def index
    @bookmarks = Bookmark.where(private: false).or(
                 current_user ? Bookmark.where(user: current_user) : Bookmark.none)
                 .order(created_at: :desc)
  end
  
  def show
    # Redirect if trying to access a private bookmark that doesn't belong to current user
    if @bookmark.private? && @bookmark.user != current_user
      redirect_to bookmarks_path, alert: "You don't have access to this bookmark"
    end
  end
  
  def new
    @bookmark = Bookmark.new
  end
  
  def create
    @bookmark = current_user.bookmarks.build(bookmark_params)
    
    # Process tags
    if params[:tag_list].present?
      tag_names = params[:tag_list].split(',').map(&:strip).reject(&:empty?)
      tag_names.each do |tag_name|
        tag = Tag.find_or_create_by(name: tag_name.downcase)
        @bookmark.tags << tag unless @bookmark.tags.include?(tag)
      end
    end
    
    if @bookmark.save
      redirect_to @bookmark, notice: 'Bookmark was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
    # Check if user is authorized to edit this bookmark
    unless @bookmark.user == current_user
      redirect_to bookmarks_path, alert: "You're not authorized to edit this bookmark"
    end
  end
  
  def update
    # Check if user is authorized to update this bookmark
    unless @bookmark.user == current_user
      return redirect_to bookmarks_path, alert: "You're not authorized to update this bookmark"
    end
    
    # First remove all existing tags
    @bookmark.bookmark_tags.destroy_all
    
    # Process tags
    if params[:tag_list].present?
      tag_names = params[:tag_list].split(',').map(&:strip).reject(&:empty?)
      tag_names.each do |tag_name|
        tag = Tag.find_or_create_by(name: tag_name.downcase)
        @bookmark.tags << tag unless @bookmark.tags.include?(tag)
      end
    end
    
    if @bookmark.update(bookmark_params)
      redirect_to @bookmark, notice: 'Bookmark was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    # Check if user is authorized to delete this bookmark
    unless @bookmark.user == current_user
      return redirect_to bookmarks_path, alert: "You're not authorized to delete this bookmark"
    end
    
    @bookmark.destroy
    redirect_to bookmarks_path, notice: 'Bookmark was successfully deleted.'
  end
  
  private
  
  def set_bookmark
    @bookmark = Bookmark.find(params[:id])
  end
  
  def bookmark_params
    params.require(:bookmark).permit(:title, :url, :description, :private)
  end
  
  def authenticate_user!
    unless current_user
      redirect_to login_path, alert: "Please log in to continue"
    end
  end
end