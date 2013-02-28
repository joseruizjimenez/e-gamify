require 'uuidtools'
require 'base64'

class UsersController < ApplicationController

  def index
  end


  def create
    @user = nil
    shop = Shop.find(params[:shop_id])
    unless shop.users.empty?
      @user = ( shop.users.each { |u| u.fb_id == params[:fb_id] } )[0]
    end
    if @user.nil?
      @user = User.new(params[:user])
      @user[:logins] = 0
      join_reward = (shop.rewards.each { |r| r.name == "Welcome!" })[0]
      @user.reward_ids.push(join_reward.id)
      Shop.set({'rewards.name' => "Welcome!"},
        {'rewards.$.redeemed' => join_reward.redeemed + 1})
    else
      @user.update_attributes(
        :name => params[:name],
        :email => params[:email],
        :fb_access_token => params[:fb_access_token]
      )
    end
    @user.update_attributes(
      :logued => true,
      :s_token => Base64.encode64(UUIDTools::UUID.random_create)[0..11],
      :logins => @user[:logins] + 1
    )
    if shop.users.empty?
      shop.users.push(@user)
    end

    shop.save!

    respond_to do |format|
      # format.html
      format.xml  { render :xml => @user }
      format.json { render :json => @user }
    end


    # user = shop.users.find_by_fb_id(params[:user].fb_id)
    # if user != nil
    #   user.set(:s_token => Base64.encode64(UUIDTools::UUID.random_create)[0..8])
    #   user.set(:logued => true)
    #   user.set(:fb_login_token => params[:user].fb_login_token)
    #   user.set(:fb_access_token => params[:user].fb_access_token)
    #   user.set(:fb_expires_at => params[:user].fb_expires_at)
    # else
    #   user = shop.users.build(params[:user])
    #   user.logued = true
    #   user.s_token = Base64.encode64(UUIDTools::UUID.random_create)[0..8]
    #   join_reward = Reward.first( :name => "Welcome!" )
    #   join_reward.increment(:redeemed => 1)
    #   join_reward.save!
    #   user.push(:reward_ids => join_reward.id)
  end


  def show
  end


  def update
  end


  def destroy
  end

end
