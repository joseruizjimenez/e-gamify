class RewardsController < ApplicationController
  before_filter :authenticate_site_owner!

  def index
    # renders reward's quests graph
    @shop = current_site_owner.shops.find params[:shop_id]
    if @shop.nil?
      redirect_to "/"
    end
  end


  def create
    #params[:reward][:redeem_hits] = params[:reward][:redeem_hits].split(",")
    @shop = current_site_owner.shops.find params[:shop_id]
    if @shop.nil?
      redirect_to "/"
    else
      @reward = @shop.rewards.build params[:reward]
      if @shop.save!
        flash[:notice] = "Success! New <b>reward added</b>!"
      else
        flash[:alert] = "Oops! We had a problem, please try again!"
      end

      respond_to do |format|
        format.xml  { render :xml => @reward }
        format.json { render :json => @reward }
        format.html { render :index }
      end
    end
  end


  def show
    @shop = current_site_owner.shops.find params[:shop_id]
    if @shop.nil?
      redirect_to "/"
    else
      @reward = (@shop.rewards.select { |r| r.id.to_s == params[:id] })[0]

      respond_to do |format|
        format.xml  { render :xml => @reward }
        format.json { render :json => @reward }
        format.html { render :index }
      end
    end
  end


  def update
    params[:reward][:redeem_hits] = params[:reward][:redeem_hits].split(",")
    .map { |h| Integer(h) unless h == 'NaN' }.compact
    params[:reward][:add_points] = params[:reward][:add_points].split(",")
    .map { |h| Integer(h) unless h == 'NaN' }.compact
    @shop = current_site_owner.shops.find params[:shop_id]
    if @shop.nil?
      redirect_to "/"
    else
      @reward = @shop.rewards.find params[:id]
      if @reward.update_attributes params[:reward]
        flash[:notice] = "Success! <b>Reward updated</b>!"
      else
        flash[:alert] = "Oops! We had a problem, please try again!"
      end

      respond_to do |format|
        format.xml  { render :xml => @reward }
        format.json { render :json => @reward }
        format.html { render :index }
      end
    end
  end


  def destroy
    @shop = current_site_owner.shops.find params[:shop_id]
    unless @shop.nil?
      @shop.rewards.delete_if {|r| r.id.to_s == params[:id]}
      if @shop.save!
        flash[:notice] = "Reward <b>deleted</b> successfully!"
      end
    end
    respond_to do |format|
      format.xml  { render :xml => @reward }
      format.json { render :json => @reward }
      format.html { render :index }
    end
  end

end