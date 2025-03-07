# app/models/bookmark.rb
class Bookmark < ApplicationRecord
  belongs_to :user
  has_many :bookmark_tags, dependent: :destroy
  has_many :tags, through: :bookmark_tags
  
  validates :title, presence: true
  validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp }
  
  # You might need to add this line to your Gemfile:
  # gem 'uri'
end