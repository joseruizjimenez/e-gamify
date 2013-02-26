class WidgetsController < ApplicationController
  def main_bar
    html = "<h1>Widget " + params[:s] + "</h1>"
    json = { html: html }.to_json
    callback = params[:callback]
    jsonp = callback + "(" + json + ")"
    render :text => jsonp, :content_type => "text/javascript"
  end

  def fb_login
  end
end
