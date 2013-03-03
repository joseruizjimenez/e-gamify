require 'uuidtools'
require 'base64'

class UsersController < ApplicationController

  def index
  end


  def create
    @user = User.first({'shop_id' => params[:shop_id], 'fb_id' => params[:fb_id]})

    if @user.nil?
      shop = Shop.find(params[:shop_id])
      @user = User.new(params[:user])
      join_reward = (shop.rewards.each { |r| r.name == "Welcome!" })[0]
      join_reward[:redeemed] = join_reward[:redeemed] + 1
      @user.reward_ids.push(join_reward.id)
      @user[:logued] = true
      @user[:s_token] = Base64.encode64(UUIDTools::UUID.random_create)[0..11]
      shop.users.push(@user)
      shop.save!
      # Shop.set({'id' => params[:shop_id], 'rewards.id' => join_reward.id},
      #   {'rewards.$.redeemed' => join_reward.redeemed + 1})
    else
      @user.update_attributes(
        :name => params[:name],
        :email => params[:email],
        :fb_access_token => params[:fb_access_token],
        :fb_login_token => params[:fb_login_token],
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
      jsonp = params[:callback] + "(" + json + ")"
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
    User.set( {'id' => params[:user_id],
      'shop_id' => params[:shop_id],
      's_token' => params[:s_token]}, {
      'logued' => false } )
  end


  def destroy
  end

end
