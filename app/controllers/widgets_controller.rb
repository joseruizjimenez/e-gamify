class WidgetsController < ApplicationController

  def fb_login
    # just renders fb_login iframe page
  end


  def fb_check
    shop = Shop.find(params[:s])
    json = { nothing: "" }.to_json
    unless shop.users.empty?
      @user = ( shop.users.each { |u| u.fb_login_token == params[:fb_lt] } )[0]
      json = @user.to_json unless @user.nil?
    end

    # answer as JSON with Padding (cross domain)
    callback = params[:callback]
    jsonp = callback + "(" + json + ")"
    render :text => jsonp, :content_type => "text/javascript"
  end

end