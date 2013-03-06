(->

  $ = undefined
  jQuery = undefined
  user = undefined
  checking = undefined
  debugger_mode = true

  blank_state_html = "<div id='e-gamify-user-wrap' style='display: none;'>
                        <div id='e-gamify-name'></div>
                        <div id='e-gamify-points'></div>
                        <div id='e-gamify-avatar'></div>
                      </div>
                      <div id='e-gamify-iframe' style='display: none;'></div>
                      <div id='e-gamify-status'><img src='http://localhost:3000/widgets/img/ajax-loader.gif'></img></div>
                      "


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
    if user_id is null or s_token is null
      return null
    else
      return { "user_id" : user_id, "s_token" : s_token }


  setUserCookies = (user) ->
    # sets user login data on cookies
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
      s.html(msg).fadeIn(500).delay(500).fadeOut(500).fadeIn(500).fadeOut(500)
      setTimeout () ->
        s.css('color', '#344D9D').fadeIn(500)
      , 2500


  updatePointsAnimation = (points, msg) ->
    p = $("#e-gamify-p")
    updateStatusMsg msg
    p.fadeOut 'fast', () ->
      p.css('color', '#81FF38').html("+ " + points).fadeIn(500).delay(500).fadeOut(500).fadeIn(500).fadeOut(500)
      setTimeout () ->
        p.css('color', '#2CE629').html(user.points).fadeIn(500)
      , 2500


  redeemVisitPoints = (user) ->
    unless user.new_points is undefined or user.new_points is null
      setTimeout () ->
        updatePointsAnimation user.new_points, user.new_points_msg
      , 500


  updateUserStatus = (logued_user) ->
    # updates user status on widged main bar
    $("#e-gamify-main-bar").hide().delay(400)
    if logued_user isnt undefined and logued_user isnt null and logued_user.name isnt undefined
      $("#e-gamify-main-bar").css 'width', '32%'
      $("#e-gamify-status").css 'color', '#344D9D'
      $("#e-gamify-iframe").hide()
      $("#e-gamify-status").html "logued in!"
      $("#e-gamify-name").html "Hi, " + logued_user.name + "!"
      $("#e-gamify-points").html "<div id='e-gamify-ep'>Earned points: </div><div id='e-gamify-p'>" + logued_user.points + "</div>"
      $("#e-gamify-avatar").html "<img src='https://graph.facebook.com/" +
        logued_user.fb_id + "/picture'>"
      $("#e-gamify-user-wrap").show()
      log "Main_bar: user LOGUED IN"
      redeemVisitPoints(logued_user)
    else
      $("#e-gamify-main-bar").css 'width', ''
      $("#e-gamify-status").css 'color', '#333333'
      login_html = "<p>Welcome to "+ logued_user.shop_name +
                   "!</p><p>Login and start <b>collecting points</b>!</p>
                    <div id=e-gamify-powered>Powered by: <a href='http://www.e-gamify.com'>e-gamify.com</a>"
      $("#e-gamify-status").html login_html
      $("#e-gamify-user-wrap").hide()
      $("#e-gamify-iframe").show()
      user = undefined
      log "Main_bar: user NOT LOGUED IN"
    $("#e-gamify-main-bar").fadeIn('slow')


  fetchUser = (shop_id, user_id, s_token) ->
    # fetchs user data from e-gamify
    log "Main_bar: fetching user data..."
    jsonp_url = "http://localhost:3000/shops/" + shop_id + "/users/" + user_id +
      "?s_token=" + s_token + "&callback=?"
    $.getJSON jsonp_url, (data) ->
      setUserCookies(data)
      if data isnt undefined and data.name isnt undefined
        log "Main_bar: user fetch finished, user set"
        user = data
      else
        log "Main_bar: ERROR fetching user"
      updateUserStatus(data)


  pollFBLoginStatus = (login_checks, freq_time, shop_id, fb_login_token) ->
    # crossdomain check fb login status each freq_time period for login_checks iterations
    jsonp_url = "http://localhost:3000/widgets/fb_check?s=" + shop_id +
      "&fb_lt=" + fb_login_token + "&callback=?"
    checking = setInterval () ->
      if (login_checks < 0 or (user isnt undefined and user.id isnt undefined))
        clearInterval checking
        setUserCookies(user)
        updateUserStatus(user)
      else
        login_checks--
        log "Main_bar: polling FB login status..."
        $.getJSON jsonp_url, (data) ->
          if data isnt undefined and data.name isnt undefined
            log "Main_bar: FB login finished, user set"
            user = data
          else
            log "Main_bar: ERROR: fetching FB login failed"
            user = data
    , freq_time


  turnOnFBClickjacking = (shop_id, fb_login_token) ->
    # activates a polling for FB login when FB button on iframe is clicked
    myConfObj = iframeMouseOver: false
    window.addEventListener "blur", ->
      if myConfObj.iframeMouseOver
        log "Main_bar: FB Login Button clicked"
        window.setTimeout(pollFBLoginStatus(30, 2000, shop_id, fb_login_token), 1000)

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
    fb_login_iframe_html = "<iframe id='e-gamify-fb-login' src='http://localhost:3000/widgets/fb_login?s=" +
      shop_id + "&fb_lt=" + fb_login_token + "' width='100%' height='200px' frameborder='0' scrolling='no'></iframe>"
    $("#e-gamify-iframe").append fb_login_iframe_html
    log "Main_bar: Loading FB_login script..."
    $("#e-gamify-fb-login").ready () ->
      autoResizeIframe("e-gamify-fb-login")

    turnOnFBClickjacking(shop_id, fb_login_token)
    pollFBLoginStatus(4, 500, shop_id, fb_login_token)


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
        href: "http://localhost:3000/widgets/css/main_bar/" + style + ".css"
      )
      css_link.appendTo "head"
      $("head").append "<link href='https://fonts.googleapis.com/css?family=Ubuntu|Open+Sans' rel='stylesheet' type='text/css'>"
      log "Main_bar: CSS and font links loaded"

      # load html spash screen
      #$("#e-gamify-main-bar").html "<div id='e-gamify-status'>comprobando...</div>"
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

)()
