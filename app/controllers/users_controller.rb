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
        :logins => @user[:logins] + 1,
        :s_token => Base64.encode64(UUIDTools::UUID.random_create)[0..11]
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
      params[:callback] ||= ""
      json = { nothing: "" }.to_json
      jsonp = params[:callback] + "(" + json + ")"
      render :text => jsonp, :content_type => "text/javascript"#, :status => :unauthorized
    else
      # new account points
      if @user.total_points == 0
        shop = Shop.find(params[:shop_id])
        welcome_reward = (shop.rewards.each { |r| r.name == "Welcome!" })[0]
        @user.redeem_reward_points welcome_reward
        @user[:new_points] = welcome_reward.add_points
        @user[:new_points_msg] = welcome_reward.add_msg
      # daily visit points
      elsif @user.updated_at + 1.day < Time.now
        @user.redeem_daily_visit_point
        @user[:new_points] = 1
        @user[:new_points_msg] = "Just won 1 point with daily visit!"
      else
        @user[:pages_visited] += 1
        @user.save!
      end
      # answer as JSON with Padding (cross domain request)
      json = @user.to_json
      params[:callback] ||= ""
      jsonp = params[:callback] + "(" + json + ")"
      respond_to do |format|
        # format.xml  { render :xml => @user }
        # format.json { render :json => @user }
        format.text { render :text => jsonp, :content_type => "text/javascript" }
        format.html
      end
    end
  end


  def logout
    # Logouts the user, he must know the right token
    User.set( {'id' => params[:user_id],
      'shop_id' => params[:shop_id],
      's_token' => params[:s_token]}, {
      'logued' => false } )
    json = { ok: "true" }.to_json
    jsonp = params[:callback] + "(" + json + ")"
    respond_to do |format|
      format.text { render :text => jsonp, :content_type => "text/javascript" }
    end
  end


  def update
  end


  def destroy
  end

end
