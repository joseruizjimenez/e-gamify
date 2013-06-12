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
      #@shop.users.each do |u|
      #  day_random = Random.new.rand(1..120)
      #  u.last_action_at = Time.now - day_random.days
      #  u.save!
      #end
      puts Time.now
      # First tab: DASHBOARD
      @total_page_views = PageView.count(shop_id: @shop.id.to_s)
      unique_visits_map = PageView.count_visits_by "ip_address",
        {:query => { shop_id: params[:shop_id] }}
      @total_unique_visits = unique_visits_map.length
      unique_reg_visits_map = PageView.count_visits_by "user_id",
        {:query => { shop_id: params[:shop_id], user_id: {'$ne' => ""} } }
      @total_unique_reg_visits = unique_reg_visits_map.length
      @page_views_last_week = PageView.count(
        :shop_id => @shop.id.to_s,
        :created_at =>
        { '$gt' => 1.week.ago.beginning_of_week, '$lt' => 1.week.ago.end_of_week }
      )
      @customers_affiliation_rate = (@total_unique_reg_visits*100/@total_unique_visits).round(1)

      monthly_visits = PageView.where(
        :shop_id => @shop.id.to_s,
        :created_at =>
        { '$gt' => 1.month.ago.beginning_of_month, '$lt' => 1.month.ago.end_of_month }
      )
      monthly_registered_visits = PageView.where(
        :shop_id => @shop.id.to_s,
        :user_id => {'$ne' => ""},
        :created_at =>
        { '$gt' => 1.month.ago.beginning_of_month, '$lt' => 1.month.ago.end_of_month }
      )
      @monthly_visits_graph = [
        { name: "Total visitors",
          data: count_grouped(monthly_visits, :created_at, 'beginning_of_day') },
        { name: "Registered visitors",
          data: count_grouped(monthly_registered_visits, :created_at, 'beginning_of_day') }
      ]
      puts Time.now

      # Second tab: REGISTERS
      @average_page_views =
        (unique_visits_map.values.inject(:+) / @total_unique_visits).round(1)
      @average_reg_page_views =
        (unique_reg_visits_map.values.inject(:+) / @total_unique_reg_visits).round(1)
      @created_users_last_week = User.count(
        :shop_id => @shop.id.to_s,
        :created_at =>
        { '$gt' => 1.week.ago.beginning_of_week, '$lt' => 1.week.ago.end_of_week }
      )
      @created_users_last_month = User.count(
        :shop_id => @shop.id.to_s,
        :created_at =>
        { '$gt' => 1.month.ago.beginning_of_month, '$lt' => 1.month.ago.end_of_month }
      )

      week_number = 1
      weekly_unique_visits = {}
      8.times do
        unique_visits_w = PageView.count_visits_by "ip_address", { :query => {
          shop_id: params[:shop_id],
          created_at: { '$gt' => week_number.weeks.ago.beginning_of_week.utc,
                        '$lt' => week_number.weeks.ago.end_of_week.utc } } }
        unique_reg_visits_w = PageView.count_visits_by "user_id", { :query => {
          shop_id: params[:shop_id],
          user_id: {'$ne' => ""},
          created_at: { '$gt' => week_number.weeks.ago.beginning_of_week.utc,
                        '$lt' => week_number.weeks.ago.end_of_week.utc } } }
        weekly_unique_visits[week_number.weeks.ago.beginning_of_week] =
          (unique_reg_visits_w.length * 100 / unique_visits_w.length).round
        week_number += 1
      end
      @weekly_customers_affiliation_graph = weekly_unique_visits
      puts Time.now

      # Third tab: ACTIONS
      # total_actions_data = User.count_actions :query => {
      #   shop_id: params[:shop_id]
      # }
      # monthly_actions_data = User.count_actions :query => {
      #   shop_id: params[:shop_id],
      #   last_action_at: { '$gt' => 1.month.ago.beginning_of_month.utc,
      #                     '$lt' => 1.month.ago.end_of_month.utc }
      # }
      # @total_actions = total_actions_data.shares + total_actions_data.likes +
      #                 total_actions_data.buys
      # @monthly_actions = monthly_actions_data.shares + monthly_actions_data.likes +
      #                 monthly_actions_data.buys
      # @total_social_actions = total_actions_data.shares + total_actions_data.likes
      # @total_buy_actions = total_actions_data.buys
      # @average_actions = @monthly_actions / monthly_actions_data.users_count
      # @monthly_actions_graph = []
      # @monthly_actions_graph["Shares"] = monthly_actions_data.shares*100 / @total_actions
      # @monthly_actions_graph["Likes"] = monthly_actions_data.likes*100 / @total_actions
      # @monthly_actions_graph["Buys"] = monthly_actions_data.buys*100 / @total_actions
      # puts Time.now

      # Fourth tab: COUPONS
    end
  end


  def count_grouped(collection, field, freq)
    group = {}
    case freq
    when 'day_of_week'
      selector = "strftime('%A')"
    when 'day_of_month'
      selector = "strftime('%d')"
    when 'day_of_year'
      selector = "strftime('%j')"
    when 'beginning_of_day'
      selector = "beginning_of_day"
    when 'beginning_of_week'
      selector = "beginning_of_week"
    when 'beginning_of_month'
      selector = "beginning_of_month"
    when 'week'
      selector = "strftime('%W')"
    when 'month'
      selector = "strftime('%B')"
    end
    collection.each do |o|
      selected_group = o.send(field).send(selector)
      group[selected_group] ||= 0
      group[selected_group] += 1
    end
    group
  end

end