class Shop
  include MongoMapper::Document

  key :name, String
  key :premium, Boolean, :default => false
  key :uri, String
  key :language, String
  key :widgets, Array
  timestamps!

  belongs_to :site_owner
  many :users
  many :rewards

end