class WidgetsController < ApplicationController

  # def main_bar
  #   html = "<h1>Widget " + params[:s] + "</h1>"
  #   json = { html: html }.to_json
  #   callback = params[:callback]
  #   jsonp = callback + "(" + json + ")"
  #   render :text => jsonp, :content_type => "text/javascript"
  # end


  def fb_login
    # just renders fb_login iframe page
  end


  def fb_check
    shop = Shop.find(params[:s])
    json = { nothing: "" }.to_json
    unless shop.users.empty?
      @user = ( shop.users.each { |u| u.fb_login_token == params[:fb_lt] } )[0]
      unless @user.nil?
        # if !@user.logued or @user.fb_expires_at < Time.now
        #   # expired fb session: need relogin
        #   @user.logued = false
        #   @user.save!
        # else
        #   json = @user.to_json
        # end
        json = @user.to_json
      end
    end

    # answer as JSON with Padding (cross domain)
    callback = params[:callback]
    jsonp = callback + "(" + json + ")"
    render :text => jsonp, :content_type => "text/javascript"

  end

end