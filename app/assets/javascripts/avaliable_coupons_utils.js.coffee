# Utils snippets for the main site, with coffee :)
# Remember: Coffe makes a clojure itself

$ = window.jQuery
used_btn = false

$(".buyable").click ->
  coupon_id = $(this).attr "coupon-id"
  coupon_cost = $(this).attr "coupon-cost"
  coupon_desc = $(this).attr "coupon-description"
  user_points = $(this).attr "user-points"
  user_id = $(this).attr "user-id"
  user_token = $(this).attr "user-token"
  shop_id = $(this).attr "shop-id"
  if parseInt(coupon_cost) <= parseInt(user_points)
    $(".redeem-msg").html "You have "+user_points+" points, do you want to get:<p></p><b>"+
    coupon_desc+"</b> using <div style='display: inline; color: green;'>"+coupon_cost+" points</div>?"
    $(".redeem-btn").find("a").attr "href", "/shops/"+shop_id+"/users/"+user_id+
    "/coupons/"+coupon_id+"/redeem?s_token="+user_token
    $(".redeem-btn").removeClass "hide"
    $(".cancel-redeem-btn").addClass "hide"
  else
    $(".redeem-msg").html "Sorry... You don't have enought points yet"
    $(".redeem-btn").addClass "hide"
    $(".cancel-redeem-btn").removeClass "hide"
  $("#redeem-coupon").modal 'show'

$(".cancel-redeem-btn").click ->
  $("#redeem-coupon").modal 'hide'

$(".usable").mouseover ->
  $(this).find(".mark-used").show()

$(".usable").mouseout ->
  $(this).find(".mark-used").hide()

$("#toggle-used").click ->
  if used_btn
    used_btn = false
    $(this).html "<a href='#'><u>Show used coupons</u></a>"
    $(".used").hide()
  else
    used_btn = true
    $(this).html "<a href='#'><u>Hide used coupons</u></a>"
    $(".used").show()
