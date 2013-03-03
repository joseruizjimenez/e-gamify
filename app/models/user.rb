class User
  include MongoMapper::EmbeddedDocument

  key :name, String
  key :email, String
  key :logued, Boolean
  key :s_token, String
  key :fb_id, String
  key :fb_login_token, String
  key :fb_access_token, String
  key :fb_expires_at, Integer
  key :points, Integer, :default => 0
  key :total_points, Integer, :default => 0
  key :actions_count, Integer, :default => 0
  key :buys_count, Integer, :default => 0
  key :likes_count, Integer, :default => 0
  key :shares_count, Integer, :default => 0
  key :pages_visited, Integer, :default => 1
  key :logins, Integer, :default => 0
  key :reward_ids, Array
  timestamps!

  embedded_in :shop
  # many :rewards, :in => :reward_ids

  def self.verify(shop_id, user_id, s_token)
    shop = Shop.find shop_id
    if shop.users.empty? then nil
    else (shop.users.each { |u| u.id == user_id and u.s_token == s_token} )[0] end
  end

end