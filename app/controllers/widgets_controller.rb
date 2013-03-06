class WidgetsController < ApplicationController

  def fb_login
    # just renders fb_login iframe page
  end


  def fb_check
    @user = User.first({'shop_id' => params[:s], 'fb_login_token' => params[:fb_lt]})
    if @user.nil?
      @shop = Shop.find params[:s]
      unless @shop.nil?
        json = { shop_name: @shop.name }.to_json
      else
        json = { shop_name: "e-gamify" }.to_json
      end
    else
      json = @user.to_json
    end

    # answer as JSON with Padding (cross domain)
    callback = params[:callback]
    jsonp = callback + "(" + json + ")"
    render :text => jsonp, :content_type => "text/javascript"
  end

end