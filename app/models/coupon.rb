class Coupon
  include MongoMapper::EmbeddedDocument

  key :description, String, :required => true
  key :cost, Integer, :required => true
  key :activate_at, Time, :default => Time.now
  key :expires_at, Time, :default => Time.now + 99.year
  key :stock, Integer, :default => -1
  key :codes, Array, :required => true
  timestamps!

  embedded_in :shop
  embedded_in :user

end