require 'uuidtools'
require 'base64'

class UsersController < ApplicationController

  def index
  end


  def create
    @user = nil
    shop = Shop.find(params[:shop_id])
    @user = ( shop.users.each { |u| u.fb_id == params[:fb_id] } )[0] unless shop.users.empty?

    if @user.nil?
      @user = User.new(params[:user])
      join_reward = (shop.rewards.each { |r| r.name == "Welcome!" })[0]
      join_reward[:redeemed] = join_reward[:redeemed] + 1
      @user.reward_ids.push(join_reward.id)
      @user[:logued] = true
      @user[:s_token] = Base64.encode64(UUIDTools::UUID.random_create)[0..11]
      shop.users.push(@user)
      #shop.rewards.push(join_reward)
      shop.save!
      # Shop.set({'id' => params[:shop_id], 'rewards.id' => join_reward.id},
      #   {'rewards.$.redeemed' => join_reward.redeemed + 1})
    else
      @user.update_attributes(
        :name => params[:name],
        :email => params[:email],
        :fb_access_token => params[:fb_access_token],
        :logued => true,
        :s_token => Base64.encode64(UUIDTools::UUID.random_create)[0..11],
        :pages_visited => @user[:pages_visited] + 1,
        :logins => @user[:logins] + 1
      )
    end

    respond_to do |format|
      # format.html
      format.xml  { render :xml => @user }
      format.json { render :json => @user }
    end
  end


  def show
    @user = User.verify params[:shop_id], params[:id], params[:s_token]
    if @user.nil?
      json = { nothing: "" }.to_json
      jsonp = callback + "(" + json + ")"
      render :text => jsonp, :status => :unauthorized
    else
      # answer as JSON with Padding (cross domain)
      json = @user.to_json
      callback = params[:callback]
      jsonp = callback + "(" + json + ")"
      respond_to do |format|
        # format.html
        # format.xml  { render :xml => @user }
        # format.json { render :json => @user }
        format.text { render :text => jsonp, :content_type => "text/javascript" }
      end
    end
  end


  def update
    # Logouts the user, he must know the right token
    Shop.set( {'id' => params[:shop_id],
      'users.id' => params[:user_id],
      'users.s_token' => params[:s_token]}, {
      'users.$.logued' => false } )
  end


  def destroy
  end

end
