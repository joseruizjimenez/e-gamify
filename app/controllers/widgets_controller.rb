class WidgetsController < ApplicationController

  def fb_login
    # just renders fb_login iframe page
  end


  def fb_check
    @user = User.first({'shop_id' => params[:s], 'fb_login_token' => params[:fb_lt]})
    shop = Shop.find params[:s]
    json = { shop_name: "e-gamify" }.to_json
    if @user.nil?
      json = { shop_name: shop.name }.to_json unless shop.nil?
    else
      # new account points
      if @user.total_points == 0
        welcome_reward = (shop.rewards.select { |r| r.name == "Welcome!" })[0]
        @user[:new_points], @user[:new_points_msg] = @user.redeem_reward_points welcome_reward
      # daily visit points
      elsif @user.updated_at + 1.day < Time.now
        @user.redeem_daily_visit_point
        @user[:new_points] = 1
        @user[:new_points_msg] = "Just won 1 point with daily visit!"
      else
        @user[:pages_visited] += 1
        @user.save!
      end
      @user[:shop_name] = shop.name
      json = @user.to_json
    end

    # answer as JSON with Padding (cross domain)
    callback = params[:callback]
    jsonp = callback + "(" + json + ")"
    render :text => jsonp, :content_type => "text/javascript"
  end

end