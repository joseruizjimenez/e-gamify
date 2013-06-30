# Remember: Coffe makes a clojure itself

$ = undefined
jQuery = undefined
user = undefined
shop_name = undefined
#e_gamify_domain = "localhost:3000"
e_gamify_domain = "e-gamify.com"
checking = undefined
printing = off
headlines = []
debugger_mode = true

blank_state_html = "<div id='e-gamify-user-wrap' style='display: none;'>
                      <div id='e-gamify-name'></div>
                      <div id='e-gamify-points'></div>
                      <div id='e-gamify-avatar'></div>
                    </div>
                    <div id='e-gamify-iframe' style='display: none;'></div>
                    <div id='e-gamify-status'><img src='https://" + e_gamify_domain +
                    "/widgets/img/ajax-loader.gif'></img></div>"

idle_status_html = "Welcome back and happy shopping!"

fonts_html = "<link href='https://fonts.googleapis.com/css?family=Ubuntu|Open+Sans' rel='stylesheet' type='text/css'>"

loginStatusHTML = ->
  "<p>Welcome to " + shop_name +
    "!</p><p>Login and start <b>collecting points</b>!</p>
    <div id=e-gamify-powered>Powered by: <a href='https://www.e-gamify.com'>e-gamify.com</a>"

fBLoginIframeHTML = (shop_id, fb_login_token) ->
  "<iframe id='e-gamify-fb-login' src='https://"+e_gamify_domain+"/widgets/fb_login?s=" +
    shop_id + "&fb_lt=" + fb_login_token + "' width='100%' height='200px' frameborder='0' scrolling='no'></iframe>"

nameHTML = (name) ->
  "Hi, " + name + "!"

avatarHTML = (fb_id, shop_id, user_id, s_token) ->
  "<img id='e-gamify-avatar-img' src='https://graph.facebook.com/" +
    fb_id + "/picture'><div id='e-gamify-avatar-menu' style='display:none;'>
    <div id='e-gamify-avatar-menu-profile'><p><a href='https://"+e_gamify_domain+"/shops/" +
    shop_id + "/users/" + user_id + "?s_token=" + s_token + "' target='_blank'>profile</a></p></div>
    <div id='e-gamify-avatar-menu-logout'><a href='#'>logout</a></div></div>"

pointsHTML = (points) ->
  "<div id='e-gamify-ep'>Earned points: </div><div id='e-gamify-p'>" + points + "</div>"


docCookies =
  getItem: (sKey) ->
    return null  if not sKey or not @hasItem(sKey)
    unescape document.cookie.replace(new RegExp("(?:^|.*;\\s*)" + escape(sKey).replace(/[\-\.\+\*]/g, "\\$&") + "\\s*\\=\\s*((?:[^;](?!;))*[^;]?).*"), "$1")

  setItem: (sKey, sValue, vEnd, sPath, sDomain, bSecure) ->
    return  if not sKey or /^(?:expires|max\-age|path|domain|secure)$/i.test(sKey)
    sExpires = ""
    if vEnd
      switch vEnd.constructor
        when Number
          sExpires = (if vEnd is Infinity then "; expires=Tue, 19 Jan 2038 03:14:07 GMT" else "; max-age=" + vEnd)
        when String
          sExpires = "; expires=" + vEnd
        when Date
          sExpires = "; expires=" + vEnd.toGMTString()
    document.cookie = escape(sKey) + "=" + escape(sValue) + sExpires + ((if sDomain then "; domain=" + sDomain else "")) + ((if sPath then "; path=" + sPath else "")) + ((if bSecure then "; secure" else ""))

  removeItem: (sKey, sPath) ->
    return  if not sKey or not @hasItem(sKey)
    document.cookie = escape(sKey) + "=; expires=Thu, 01 Jan 1970 00:00:00 GMT" + ((if sPath then "; path=" + sPath else ""))

  hasItem: (sKey) ->
    (new RegExp("(?:^|;\\s*)" + escape(sKey).replace(/[\-\.\+\*]/g, "\\$&") + "\\s*\\=")).test document.cookie


log = (msg)->
  # set debugger_mode true to get console logs
  if debugger_mode
    console.log msg


loginToken = ->
  # generates a login token to check users login through crossdomain
  return Math.random().toString(36).substr(2) + Math.random().toString(36).substr(2)


getUserCookies = ->
  # checks the presence of user login data on cookies
  user_id = docCookies.getItem("egamify_u")
  s_token = docCookies.getItem("egamify_t")
  shop_name = docCookies.getItem("egamify_s")
  if user_id is null or s_token is null
    return null
  else
    return { "user_id" : user_id, "s_token" : s_token }


setUserCookies = (user) ->
  # sets user login data on cookies
  if user isnt undefined and user.shop_name isnt undefined
    shop_name = user.shop_name
    docCookies.setItem("egamify_s", shop_name, Infinity, "/")
  if user is undefined or user is null or user.id is undefined
    docCookies.removeItem("egamify_u", "/")
    docCookies.removeItem("egamify_t", "/")
  else
    docCookies.setItem("egamify_u", user.id, Infinity, "/")
    docCookies.setItem("egamify_t", user.s_token, Infinity, "/")
  log "Main_bar: User login cookie set"


updateStatusMsg = (msg) ->
  s = $("#e-gamify-status")
  s.fadeOut 'fast', () ->
    s.css('color', '#3874FF')
    s.html(msg).fadeIn(500).delay(500).fadeOut(500).fadeIn(500).delay(200).fadeOut(500).fadeIn(500).delay(200).fadeOut(500).fadeIn(500).delay(200).fadeOut(500)
    setTimeout () ->
      s.css('color', '#344D9D').fadeIn(500)
    , 5100


updatePointsAnimation = (msg, points) ->
  unless msg is undefined or msg is ''
    updateStatusMsg msg
  unless points is 0
    p = $("#e-gamify-p")
    p.fadeOut 'fast', () ->
      p.css('color', '#00EB10').html("+ " + points).fadeIn(500).delay(500).fadeOut(500).fadeIn(500).delay(200).fadeOut(500).fadeIn(500).delay(200).fadeOut(500).fadeIn(500).delay(200).fadeOut(500)
      setTimeout () ->
        p.css('color', '#20D31D').html(user.points).fadeIn(500)
      , 5100


headlineMarquee = (msg, points) ->
  # Prints reward headlines on marquee, queuing them if needed with closure
  if msg isnt undefined
    headlines.push([msg, points])
  unless printing is on and headlines.length isnt 0
    printing = on
    headline = headlines.shift()
    updatePointsAnimation headline[0], headline[1]
    setTimeout () ->
      printing = off
      if headlines.length isnt 0
        headlineMarquee undefined, undefined
      else
        # headlines = anuncios
        # headlineMarquee undefined, undefined
    , 3500


redeemReward = (reward_id, shop_id, user_id, s_token) ->
  # posts a reward to the server, redeeming it, then queue his headline
  log "Main_bar: Redeeming reward " + reward_id
  jsonp_url = "https://"+e_gamify_domain+"/shops/"+shop_id+"/users/"+user_id+"/redeem/"+reward_id+"?s_token="+s_token+"&callback=?"
  $.getJSON jsonp_url, (data) ->
    if data isnt undefined and data.new_points isnt undefined
      log "Main_bar: Reward "+reward_id+" redeemed ("+data.new_points_msg+"+"+data.new_points+"p)"
      user = data
      headlineMarquee data.new_points_msg, data.new_points
    else
      log "Main_bar: ERROR redeeming reward: " + reward_id


parseRewards = (shop_id, user_id, s_token) ->
  log "Main_bar: Parsing rewards..."
  $("div.e-gamify-reward").each () ->
    reward_id = $(this).attr "reward-id"
    log "Main_bar: Reward " + reward_id + " found"
    redeemReward reward_id, shop_id, user_id, s_token


activateRewardButtons = (shop_id, user_id, s_token) ->
  # it can be improved with a security token to validate these actions
  reward_div = undefined
  $("div.e-gamify-social-btn").click ->
    log "Main_bar: Social button pushed"
    reward_id = $(this).attr "reward-id"
    $(this).unbind "click"
    redeemReward reward_id, shop_id, user_id, s_token

  myConfObj = iframeMouseOver: false
  window.addEventListener "blur", ->
    if myConfObj.iframeMouseOver
      log "Main_bar: Social button pushed"
      myConfObj.iframeMouseOver = false
      reward_id = reward_div.attr "reward-id"
      reward_div.unbind "mouseover"
      redeemReward reward_id, shop_id, user_id, s_token

  $("div.e-gamify-social-btn").mouseover ->
    reward_div = $(this)
    myConfObj.iframeMouseOver = true

  $("div.e-gamify-social-btn").mouseout ->
    myConfObj.iframeMouseOver = false


redeemPoints = (user, shop_id) ->
  unless user.new_points is undefined or user.new_points is null
    headlineMarquee user.new_points_msg, user.new_points
  activateRewardButtons shop_id, user.id, user.s_token
  parseRewards shop_id, user.id, user.s_token


logoutUser = (user, shop_id, s_token) ->
  setUserCookies undefined
  jsonp_url = "https://"+e_gamify_domain+"/shops/"+shop_id+"/users/"+user.id+"/logout?s_token="+s_token+"&callback=?"
  $.getJSON jsonp_url, (data) ->
    setUserCookies(data)
    if data isnt undefined and data.ok
      updateUserStatus undefined, undefined, undefined
      loadFBLoginScript(shop_id)
      log "Main_bar: User logued out successfully"


updateUserStatus = (logued_user, shop_id, s_token) ->
  # updates user status on widged main bar
  $("#e-gamify-main-bar").hide().delay(400)
  if logued_user isnt undefined and logued_user isnt null and logued_user.name isnt undefined
    $("#e-gamify-main-bar").css 'width', '32%'
    $("#e-gamify-status").css 'color', '#344D9D'
    $("#e-gamify-iframe").hide()
    $("#e-gamify-status").html idle_status_html
    $("#e-gamify-name").html nameHTML logued_user.name
    $("#e-gamify-points").html pointsHTML logued_user.points
    $("#e-gamify-avatar").html avatarHTML logued_user.fb_id, shop_id, logued_user.id, s_token
    $("#e-gamify-avatar").hover () ->
      $("#e-gamify-avatar-img").hide()
      $("#e-gamify-avatar-menu").fadeIn()
    , () ->
      $("#e-gamify-avatar-menu").hide()
      $("#e-gamify-avatar-img").show()
    $("#e-gamify-avatar-menu-logout").click ->
      logoutUser logued_user, shop_id, s_token
    $("#e-gamify-user-wrap").show()
    log "Main_bar: user LOGUED IN"
    redeemPoints logued_user, shop_id
  else
    $("#e-gamify-main-bar").css 'width', ''
    $("#e-gamify-status").css 'color', '#333333'
    $("#e-gamify-status").html loginStatusHTML
    $("#e-gamify-user-wrap").hide()
    $("#e-gamify-iframe").show()
    user = undefined
    log "Main_bar: user NOT LOGUED IN"
  $("#e-gamify-main-bar").fadeIn('slow')


fetchUser = (shop_id, user_id, s_token) ->
  # fetchs user data from e-gamify
  log "Main_bar: fetching user data..."
  jsonp_url = "https://"+e_gamify_domain+"/shops/"+shop_id+"/users/"+user_id+"?s_token="+s_token+"&callback=?"
  $.getJSON jsonp_url, (data) ->
    setUserCookies(data)
    if data isnt undefined and data.name isnt undefined
      log "Main_bar: user fetch finished, user set"
      user = data
      updateUserStatus(data, shop_id, s_token)
    else
      log "Main_bar: ERROR fetching user. Loading FB script"
      loadFBLoginScript(shop_id)


pollFBLoginStatus = (login_checks, freq_time, shop_id, fb_login_token) ->
  # crossdomain check fb login status each freq_time period for login_checks iterations
  jsonp_url = "https://"+e_gamify_domain+"/widgets/fb_check?s=" + shop_id +
    "&fb_lt=" + fb_login_token + "&callback=?"
  checking = setInterval () ->
    if (login_checks < 0 or (user isnt undefined and user.id isnt undefined))
      clearInterval checking
      setUserCookies(user)
      updateUserStatus(user, shop_id, user.s_token)
    else
      login_checks--
      log "Main_bar: polling FB login status..."
      $.getJSON jsonp_url, (data) ->
        if data isnt undefined and data.name isnt undefined
          log "Main_bar: FB login finished, user set"
          user = data
        else
          log "Main_bar: Not logued, fetching FB login failed"
          user = data
  , freq_time


turnOnFBClickjacking = (shop_id, fb_login_token) ->
  # activates a polling for FB login when FB button on iframe is clicked
  myConfObj = iframeMouseOver: false
  window.addEventListener "blur", ->
    if myConfObj.iframeMouseOver
      log "Main_bar: FB Login Button clicked"
      window.setTimeout(pollFBLoginStatus(30, 700, shop_id, fb_login_token), 1000)

  document.getElementById("e-gamify-fb-login").addEventListener "mouseover", ->
    myConfObj.iframeMouseOver = true

  document.getElementById("e-gamify-fb-login").addEventListener "mouseout", ->
    myConfObj.iframeMouseOver = false


autoResizeIframe = (id) ->
  newheight = undefined
  newwidth = undefined
  if document.getElementById
    newheight = document.getElementById(id).contentWindow.document.body.scrollHeight
    newwidth = document.getElementById(id).contentWindow.document.body.scrollWidth
  document.getElementById(id).height = (newheight) + "px"
  document.getElementById(id).width = (newwidth) + "px"


loadFBLoginScript = (shop_id) ->
  # loads FB login iframe and starts polling for logins
  fb_login_token = loginToken()
  $("#e-gamify-iframe").html fBLoginIframeHTML shop_id, fb_login_token
  log "Main_bar: Loading FB_login script..."
  $("#e-gamify-fb-login").ready () ->
    autoResizeIframe("e-gamify-fb-login")

  turnOnFBClickjacking(shop_id, fb_login_token)
  pollFBLoginStatus(1, 500, shop_id, fb_login_token)


scriptLoadHandler = ->
  # called once jquery has loaded
  # restore $ and window.jQuery to their previous values
  # and store the new jQuery in our local variable
  jQuery = window.jQuery.noConflict(true)
  $ = jQuery
  main()


main = ->
  jQuery(document).ready ($) ->
    # load css
    style = $("#e-gamify-main-bar").attr("theme")
    style = "classic" if style is `undefined`
    css_link = $("<link>",
      rel: "stylesheet"
      type: "text/css"
      href: "https://"+e_gamify_domain+"/widgets/css/main_bar/" + style + ".css"
    )
    css_link.appendTo "head"
    $("head").append fonts_html
    log "Main_bar: CSS and font links loaded"

    # load html spash screen
    $("#e-gamify-main-bar").html blank_state_html
    $("#e-gamify-main-bar").slideDown()#.fadeIn(800)

    shop_id = $("#e-gamify-main-bar").attr("shop")
    user_cookie = getUserCookies()
    if user_cookie is null
      log "Main_bar: user cookie not present"
      loadFBLoginScript(shop_id)
    else
      log "Main_bar: user cookie present"
      fetchUser(shop_id, user_cookie.user_id, user_cookie.s_token)



if window.jQuery is `undefined` or window.jQuery.fn.jquery isnt ("1.9.1" or "1.9.0" or
      "1.8.3" or "1.8.2" or "1.8.1" or "1.8.0" or "1.7.2" or "1.7.1" or "1.7.0" or
      "1.6.4" or "1.6.3" or "1.6.2" or "1.6.1" or "1.6.0")
  script_tag = document.createElement("script")
  script_tag.setAttribute "src", "https://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"
  script_tag.setAttribute "type", "text/javascript"
  log "Main_bar: jQuery not present, loading async version..."
  if script_tag.readyState
    # for old IE versions
    script_tag.onreadystatechange = ->
      scriptLoadHandler()  if @readyState is "complete" or @readyState is "loaded"
  else
    # and other browsers
    script_tag.onload = scriptLoadHandler
  # try to find the head, otherwise default to the documentElement
  (document.getElementsByTagName("head")[0] or document.documentElement).appendChild script_tag
else
  jQuery = window.jQuery
  $ = window.jQuery
  log "Main_bar: jQuery ready"
  main()
