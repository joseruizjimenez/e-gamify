class Reward
  include MongoMapper::EmbeddedDocument

  key :name, String, :required => true
  key :info, String
  key :cost, Integer
  key :available, Integer, :default => -1
  key :redeemed, Integer, :default => 0
  key :img_uri, String
  key :info_uri, String
  key :active, Boolean, :default => true
  key :activate_at, Time
  key :expire_at, Time
  timestamps!

  embedded_in :shop

end