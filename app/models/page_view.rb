class PageView
  include MongoMapper::Document

  key :shop_id, String, :required => false
  key :user_id, String, :required => false
  key :refered, String, :required => false
  key :ip_address, String, :required => false
  key :user_agent, String, :required => false
  timestamps!

end
