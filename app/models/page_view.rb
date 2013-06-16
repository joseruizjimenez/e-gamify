class PageView
  include MongoMapper::Document

  key :shop_id, String, :required => false
  key :user_id, String, :required => false
  key :referer, String, :required => false
  key :ip_address, String, :required => false
  key :user_agent, String, :required => false
  key :controller, String, :required => false
  key :action, String, :required => false
  timestamps!


  def self.count_visits_by(field, opts={})
    opts[:out] = "map_reduce_results"
    map = "function() {emit(this." + field + ", { count: 1 });}"
    reduce = <<-REDUCE
                function(k, v) {
                  var count = 0;
                  for (var i in v) {
                    count += 1;
                  }
                  return { count: count };
                }
              REDUCE

    data = {}
    a = PageView.collection.map_reduce(map, reduce, opts).find().each do |v|
      data[v["_id"]] = v["value"]["count"]
    end
    data
  end


  def self.count_mobile_visits(opts={})
    opts[:out] = "map_reduce_results"
    map = <<-MAP
              function() {
                var re = /Mobile|webOS/;
                if (re.test(this.user_agent)) {
                  emit( this.shop_id, { count: 1 } );
                }
              }
            MAP
    reduce = <<-REDUCE
                function(k, v) {
                  var count = 0;
                  for (var i in v) {
                    count += 1;
                  }
                  return { count: count };
                }
              REDUCE

    data = nil
    a = PageView.collection.map_reduce(map, reduce, opts).find().each do |v|
      data = v["value"]["count"]
    end
    data
  end

end
