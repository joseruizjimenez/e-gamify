class ApplicationController < ActionController::Base
  protect_from_forgery

  after_filter :pageview

  def pageview
    params[:shop_id].nil? ? shop_id = "" : shop_id = params[:shop_id]
    user_id = ""
    unless params[:s_token].nil?
      params[:user_id].nil? ? user_id = params[:id] : user_id = params[:user_id]
    end
    PageView.create shop_id: shop_id,
                    user_id: user_id,
                    referer: request.referer,
                    ip_address: request.remote_ip,
                    user_agent: request.env["HTTP_USER_AGENT"],
                    controller: params[:controller],
                    action: params[:action]
  end


  def create_random_visits
    200.times do
      shop_id = "51a1ec77abd737088f000067"
      a_random = Random.new.rand(1..254)
      b_random = Random.new.rand(2..254)
      #user_id = "51b3036eabd737432d000"+a_random.to_s
      user_id = ""
      n_random = Random.new.rand(1..10)
      referer = "http://egamify.myshopify.com/products/product-"+n_random.to_s
      remote_ip = "65.13."+a_random.to_s+"."+b_random.to_s
      user_agent = request.env["HTTP_USER_AGENT"]
      user_agent += "Mobile" if n_random > 7
      controller = ["users", "coupons", "rewards", "shops"].sample
      action = ["index", "show", "redeem", "create"].sample

      view = PageView.create shop_id: shop_id,
                            user_id: user_id,
                            referer: referer,
                            ip_address: remote_ip,
                            user_agent: user_agent,
                            controller: controller,
                            action: action
      day_random = Random.new.rand(1..60)
      view.created_at = Time.now - day_random.days
      view.save!
    end
  end


  def create_random_users
    80.times do
      day_random = Random.new.rand(1..60)
      user_params = {
        name: ['Andy ', 'Larry ', 'Mike ', 'Bob ', 'Gordon ', 'Jonh '].sample +
              ['Anderson', 'Patrick', 'Harrison', 'Ford', 'Obama'].sample,
        email: ['Andy', 'Larry', 'Mike', 'Bob', 'Gordon', 'Jonh'].sample +
               "@" + ['gmail', 'yahoo', 'bing', 'apple'].sample + ".com",
        logued: [true, false].sample,
        s_token: Base64.encode64(UUIDTools::UUID.random_create)[0..11],
        fb_id: Base64.encode64(UUIDTools::UUID.random_create)[0..11],
        fb_login_token: Base64.encode64(UUIDTools::UUID.random_create)[0..11],
        fb_access_token: Base64.encode64(UUIDTools::UUID.random_create)[0..11],
        fb_expires_at: Random.new.rand(523..6421),
        points: Random.new.rand(43..510),
        total_points: Random.new.rand(43..810),
        actions_count: Random.new.rand(15..250),
        buys_count: Random.new.rand(0..35),
        likes_count: Random.new.rand(0..90),
        shares_count: Random.new.rand(0..90),
        pages_visited: Random.new.rand(1..110),
        logins: Random.new.rand(1..30),
        visited_at: Time.now - day_random.days,
        redeemed_rewards: {},
        reward_hits: {},
        coupons: []
      }
      Random.new.rand(1..28).times do
        r = ['51b115e0abd737432d00005f', '51a1ec77abd737088f000069',
             '51a1ec77abd737088f000068', '51b115e0abd737432d00005f',
             '51b115e0abd737432d000' + Random.new.rand(100..999).to_s]
        user_params[:redeemed_rewards][r.sample] = Random.new.rand(1..41)
        user_params[:reward_hits][r.sample] = Random.new.rand(1..41)
      end
      Random.new.rand(0..4).times do
        c = ["5% off your next purchase", "Cupid shares love! (15% off)",
             "20% off your next purchase", "10% off your next purchase"]
        user_params[:coupons].push({description: c.sample})
      end
      shop_id = "51a1ec77abd737088f000067"
      shop = Shop.find shop_id
      user = shop.users.create user_params

      day_random = Random.new.rand(1..120)
      user.coupons.each { |c| c.created_at = Time.now - day_random.days }

      day_random = Random.new.rand(1..120)
      user.created_at = Time.now - day_random.days
      user.save!
    end
  end

end
