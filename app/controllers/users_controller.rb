class UsersController < ApplicationController

  def index
  end

  def create
    shop = Shop.find(params[:shop_id])
    user = shop.users.first(:fb_id => params[:user].fb_id)
    if user != nil
      user.set(:s_token => Base64.encode64(UUIDTools::UUID.random_create)[0..8])
      user.set(:logued => true)
      user.set(:fb_login_token => params[:user].fb_login_token)
      user.set(:fb_access_token => params[:user].fb_access_token)
      user.set(:fb_expires_at => params[:user].fb_expires_at)
    else
      user = shop.users.build(params[:user])
      user.logued = true
      user.s_token = Base64.encode64(UUIDTools::UUID.random_create)[0..8]
      join_reward = Reward.first( :name => "Welcome!" )
      join_reward.increment(:redeemed => 1)
      join_reward.save!
      user.push(:reward_ids => join_reward.id)
    shop.save!

    # return json user
  end

  def show
  end

  def update
  end

  def destroy
  end

end
