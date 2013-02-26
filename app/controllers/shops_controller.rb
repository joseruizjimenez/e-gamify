class ShopsController < ApplicationController

  def index
  end

  def create
    shop = Shop.new(params[:shop])
    join_reward = {
      name: "Welcome!",
      info: "Now you can start getting rewards!",
      cost: 0,
      img_uri: "/img/rewards/join.png",
      activate_at: Time.now
    }
    shop.rewards.build(join_reward)
    shop.save!
  end

  def show
  end

  def update
  end

  def destroy
  end

end