(->

  $ = undefined
  jQuery = undefined
  user = undefined
  checking = undefined
  debugger_mode = true

  blank_state_html = "<div id='e-gamify-user-wrap' style='display: none;'>
                        <div id='e-gamify-points'></div>
                        <div id='e-gamify-avatar'></div>
                        <div id='e-gamify-name'></div>
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


  updateUserStatus = (logued_user) ->
    # updates user status on widged main bar
    $("#e-gamify-main-bar").hide().delay(400)
    if logued_user isnt undefined and logued_user isnt null and logued_user.name isnt undefined
      $("#e-gamify-iframe").hide()
      $("#e-gamify-status").html "logueado!"
      $("#e-gamify-name").html logued_user.name
      $("#e-gamify-points").html logued_user.points
      $("#e-gamify-avatar").html "<img src='https://graph.facebook.com/" +
        logued_user.fb_id + "/picture'>"
      $("#e-gamify-user-wrap").show()
      log "Main_bar: user LOGUED IN"
    else
      $("#e-gamify-status").html "NO logueado"
      $("#e-gamify-user-wrap").hide()
      #$("#e-gamify-fb-login").removeAttr('style')
      $("#e-gamify-iframe").show()
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
            user = undefined
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
    log "RESIZEEE"
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
    $("#e-gamify-fb-login").change () ->
      autoResizeIframe(id)

    turnOnFBClickjacking(shop_id, fb_login_token)
    pollFBLoginStatus(5, 1000, shop_id, fb_login_token)


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
