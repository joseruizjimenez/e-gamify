class User
  include MongoMapper::Document

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
  key :logins, Integer, :default => 1
  key :reward_ids, Array
  timestamps!

  belongs_to :shop
  # many :rewards, :in => :reward_ids

  def self.verify(shop_id, user_id, s_token)
    return User.first({'shop_id' => shop_id, 'id' => user_id, 's_token' => s_token})
  end

  def redeem_reward_points(reward)
    # TODO add transaction
    self.reward_ids.push reward.id
    self.total_points += reward.add_points
    self.points += reward.add_points
    if self.save!
      reward.redeemed += 1
      reward.save!
    end
  end

  def redeem_daily_visit_point
    self.points += 1
    self.total_points += 1
    self.pages_visited += 1
    self.logins += 1
    @user.save!
  end

end