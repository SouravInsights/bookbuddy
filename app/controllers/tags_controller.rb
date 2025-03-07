class TagsController < ApplicationController
  def index
    @tags = Tag.joins(:bookmarks)
               .select('tags.*, COUNT(bookmarks.id) as bookmark_count')
               .where(bookmarks: { private: false })
               .or(Tag.joins(:bookmarks).where(bookmarks: { user: current_user }))
               .group('tags.id')
               .order('bookmark_count DESC, name ASC')
  end
  
  def show
    @tag = Tag.find(params[:id])
    @bookmarks = @tag.bookmarks.where(private: false).or(
                 @tag.bookmarks.where(user: current_user))
                .order(created_at: :desc)
  end
end