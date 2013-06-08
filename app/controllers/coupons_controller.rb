class CouponsController < ApplicationController
  before_filter :authenticate_site_owner!, :except => [:index, :redeem]

  def index
    @shop = Shop.find params[:shop_id]
    if @shop.nil?
      redirect_to "/"
    elsif params[:user_id]
      # Renders coupons avaliable to be redeemed
      @user = User.verify params[:shop_id], params[:user_id], params[:s_token]
      if @user
        render :avaliable_coupons
      else
        redirect_to "/"
      end
    elsif current_site_owner
      render :index
    else
      redirect_to "/"
    end
  end


  def new
    @shop = current_site_owner.shops.find params[:shop_id]
  end


  def create
    params[:coupon][:codes] = params[:coupon][:codes].split(",")
    if params[:coupon][:stock] == ""
      params[:coupon][:stock] = "-1"
    end
    params[:coupon][:'activate_at'] = params[:coupon][:'activate_at(1i)']+"-"+
    params[:coupon][:'activate_at(2i)']+"-"+ params[:coupon][:'activate_at(3i)']
    params[:coupon].delete :'activate_at(1i)'
    params[:coupon].delete :'activate_at(2i)'
    params[:coupon].delete :'activate_at(3i)'
    if params[:coupon][:'expires_at(1i)'] == ""
      params[:coupon][:'expires_at'] = "2023-1-1"
    else
      params[:coupon][:'expires_at'] = params[:coupon][:'expires_at(1i)']+"-"+
      params[:coupon][:'expires_at(2i)']+"-"+ params[:coupon][:'expires_at(3i)']
    end
    params[:coupon].delete :'expires_at(1i)'
    params[:coupon].delete :'expires_at(2i)'
    params[:coupon].delete :'expires_at(3i)'
    @shop = current_site_owner.shops.find params[:shop_id]
    if @shop.nil?
      redirect_to "/"
    else
      @coupon = @shop.coupons.build params[:coupon]
      if @shop.save!
        flash[:notice] = "Success! New <b>coupon added</b>!"
      else
        flash[:alert] = "Oops! We had a problem, please try again!"
      end
      respond_to do |format|
        format.xml  { render :xml => @coupon }
        format.json { render :json => @coupon }
        format.html { render :index }
      end
    end
  end


  def edit
    @shop = current_site_owner.shops.find params[:shop_id]
    @coupon = @shop.coupons.find params[:id]
  end


  def update
    params[:coupon][:codes] = params[:coupon][:codes].split(",")
    if params[:coupon][:stock] == ""
      params[:coupon][:stock] = "-1"
    end
    params[:coupon][:'activate_at'] = params[:coupon][:'activate_at(1i)']+"-"+
    params[:coupon][:'activate_at(2i)']+"-"+ params[:coupon][:'activate_at(3i)']
    params[:coupon].delete :'activate_at(1i)'
    params[:coupon].delete :'activate_at(2i)'
    params[:coupon].delete :'activate_at(3i)'
    unless params[:coupon][:'expires_at(1i)'] == ""
      params[:coupon][:'expires_at'] = params[:coupon][:'expires_at(1i)']+"-"+
      params[:coupon][:'expires_at(2i)']+"-"+ params[:coupon][:'expires_at(3i)']
    end
    params[:coupon].delete :'expires_at(1i)'
    params[:coupon].delete :'expires_at(2i)'
    params[:coupon].delete :'expires_at(3i)'
    @shop = current_site_owner.shops.find params[:shop_id]
    if @shop.nil?
      redirect_to "/"
    else
      @coupon = @shop.coupons.find params[:id]
      if @coupon.update_attributes params[:coupon]
        flash[:notice] = "Success! <b>coupon updated</b>!"
      else
        flash[:alert] = "Oops! We had a problem, please try again!"
      end
      respond_to do |format|
        format.xml  { render :xml => @coupon }
        format.json { render :json => @coupon }
        format.html { render :index }
      end
    end
  end


  def destroy
    @shop = current_site_owner.shops.find params[:shop_id]
    unless @shop.nil?
      @shop.coupons.delete_if {|c| c.id.to_s == params[:id]}
      if @shop.save!
        flash[:notice] = "Coupon <b>deleted</b> successfully!"
      end
    end
    respond_to do |format|
      format.xml  { render :xml => {} }
      format.json { render :json => {} }
      format.html { render :index }
    end
  end

  def redeem
    @shop = Shop.find params[:shop_id]
    if @shop.nil?
      redirect_to "/"
    elsif params[:user_id]
      @user = User.verify params[:shop_id], params[:user_id], params[:s_token]
      if @user
        @coupon = @shop.coupons.find params[:coupon_id]
        if @coupon.stock == 0 or @coupon.expires_at < Time.now or @coupon.cost > @user.points
          flash[:alert] = "Oops, we can't sell you that!"
        else
          new_code = @coupon.codes[0]
          @coupon.stock -= 1 if @coupon.stock > 0
          if @coupon.stock == 0 and @coupon.codes.length > 1
            new_code = @coupon.codes.shift
            @coupon.stock = 1
          end
          if @coupon.save!
            @user.points -= @coupon.cost
            bought_coupon = {
              description: @coupon.description,
              cost: @coupon.cost,
              activate_at: @coupon.activate_at,
              expires_at: @coupon.expires_at,
              codes: [new_code]
            }
            @user_coupon = @user.coupons.build bought_coupon
            if @user.save!
              flash[:notice] = "You just got a <b>"+@coupon.description+"</b> coupon!"
            else
              flash[:alert] = "Oops, we've got a problem, try again..."
            end
          else
            flash[:alert] = "Oops, we've got a problem, try again..."
          end
        end
        respond_to do |format|
          format.xml  { render :xml => @user_coupon }
          format.json { render :json => @user_coupon }
          format.html { render :avaliable_coupons }
        end
      else
        redirect_to "/"
      end
    end
  end

  def used
    # Marks a coupon as used by the user
    @shop = Shop.find params[:shop_id]
    if @shop.nil?
      redirect_to "/"
    elsif params[:user_id]
      @user = User.verify params[:shop_id], params[:user_id], params[:s_token]
      if @user
        @coupon = @user.coupons.find params[:coupon_id]
        if @coupon.stock == 0
          @coupon.stock = -1
        else
          @coupon.stock = 0
        end
        @coupon.save!
        respond_to do |format|
          format.xml  { render :xml => @coupon }
          format.json { render :json => @coupon }
          format.html { render :avaliable_coupons }
        end
      else
        redirect_to "/"
      end
    end
  end

end
