class User
  include MongoMapper::Document

  key :name, String
  key :email, String
  key :logued, Boolean
  key :s_token, String
  key :fb_id, String
  key :fb_login_token, String
  key :fb_access_token, String
  key :fb_expires_at, Integer
  key :points, Integer, :default => 0
  key :total_points, Integer, :default => 0
  # simplificar todas las acciones en un hash de: {reward_id : contador_acciones, ...}
  # pq los servicios de compras, likes, shares y pages visited seran ejemplos de
  # como crear e insertar rewards. Te vendran por defecto y se pueden quitar.
  # El main_bar checkea la pagina buscando tags de id: e-gamify-reward, y pilla su reward_id
  # si hay varios, los encola: bucle que activa el siguiente tras pinchar el aceptar de la
  # ventana modal. Onclick: procesa del array y elminina en accept.
  # La presentacion de reward, si detecta que es reward tocho, crea además la vent. modal
  # nota: hacer un reward copia de pages_visited pero no quitarlo.
  # nota2: crear otro reward de fidelidad: tiempo registrado, 1 mes, 3 meses, 1 2 3 5 años.
  #        este check se hace igual que en del punto diario.
  key :actions_count, Integer, :default => 0
  key :buys_count, Integer, :default => 0
  key :likes_count, Integer, :default => 0
  key :shares_count, Integer, :default => 0
  key :pages_visited, Integer, :default => 1
  key :logins, Integer, :default => 1
  key :visited_at, Time
  key :reward_ids, Array
  timestamps!

  belongs_to :shop
  # many :rewards, :in => :reward_ids

  def self.verify(shop_id, user_id, s_token)
    return User.first({'shop_id' => shop_id, 'id' => user_id, 's_token' => s_token})
  end

  def redeem_reward_points(reward)
    # TODO add transaction
    self.reward_ids.push reward.id
    self.total_points += reward.add_points
    self.points += reward.add_points
    if self.save!
      reward.redeemed += 1
      reward.save!
    end
  end

  def redeem_daily_visit_point
    self.points += 1
    self.total_points += 1
    self.pages_visited += 1
    self.logins += 1
    self.visited_at = Time.now
    self.save!
  end

end