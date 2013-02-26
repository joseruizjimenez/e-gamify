class Reward
  include MongoMapper::Document

  key :name, String
  key :info, String
  key :cost, Integer
  key :available, Integer, :default => 0
  key :redeemed, Integer, :default => 0
  key :img_uri, String
  key :info_uri, String
  key :active, Boolean, :default => true
  key :activate_at, Date
  key :expire_at, Date
  timestamps!

  belongs_to :shop

end