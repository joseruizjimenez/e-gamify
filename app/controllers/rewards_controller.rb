class RewardsController < ApplicationController

  def index
    # renders reward's quests graph
    @shop = Shop.find params[:shop_id]
  end


  def create
    @shop = Shop.find params[:shop_id]
    @reward = shop.rewards.create params[:reward]

    respond_to do |format|
      format.xml  { render :xml => @reward }
      format.json { render :json => @reward }
      format.html { render :index }
    end
  end


  def show
    @shop = Shop.find params[:shop_id]
    @reward = (@shop.rewards.select { |r| r.id.to_s == params[:id] })[0]

    respond_to do |format|
      format.xml  { render :xml => @reward }
      format.json { render :json => @reward }
      format.html { render :index }
    end
  end


  def update
  end


  def destroy
  end

end