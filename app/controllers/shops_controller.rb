class ShopsController < ApplicationController
  before_filter :authenticate_site_owner!

  def index
  end


  def create
    @shop = current_site_owner.shops.build params[:shop]
    welcome_reward = {
      name: "Welcome!",
      info: "Now you can start getting rewards!",
      init: true,
      add_points: [15],
      add_msg: "Just won 15 points with your first login!",
      cost: 0,
      img_uri: "/img/rewards/swap-bag.png",
      activate_at: Time.now
    }
    like_reward = {
      name: "likes",
      info: "We like that you like it...",
      init: true,
      repeatable: true,
      redeem_hits: [5],
      add_points: [1],
      add_msg: "Just won 1 point with your like!",
      cost: 0,
      img_uri: "/img/rewards/shining-heart.png",
      activate_at: Time.now
    }
    share_reward = {
      name: "sharing",
      info: "Thanks for sharing some love!",
      init: true,
      repeatable: true,
      add_points: [1],
      add_msg: "Just won 1 points with your sharing!",
      cost: 0,
      img_uri: "/img/rewards/conversation.png",
      activate_at: Time.now
    }
    @shop.rewards.build welcome_reward
    @shop.rewards.build like_reward
    @shop.rewards.build share_reward
    if @shop.save!
      flash[:notice] = "Success! Your shop was <b>created</b>!"
    else
      flash[:alert] = "Oops! We had a problem, please try again!"
    end

    respond_to do |format|
      format.xml  { render :xml => @shop }
      format.json { render :json => @shop }
      format.html { render :show }
    end
  end


  def new
  end


  def show
    @shop = current_site_owner.shops.find params[:id]
    if @shop.nil?
      redirect_to "/"
    else
      respond_to do |format|
        format.xml  { render :xml => @shop }
        format.json { render :json => @shop }
        format.html { render :show }
      end
    end
  end


  def update
  end


  def destroy
    shop = current_site_owner.shops.find params[:id]
    unless shop.nil?
      shop.destroy
      flash[:notice] = "Your shop was <b>deleted</b> successfully!"
    end
    redirect_to "/"
  end


  def analytics
    @shop = current_site_owner.shops.find params[:shop_id]
    if @shop.nil?
      redirect_to "/"
    else
      # TODO: fallback to analytics haml
    end
  end

end