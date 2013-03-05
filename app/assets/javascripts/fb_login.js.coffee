(->

  fb_app_id = "451013134972296"
  fb_login_token = undefined
  shop_id = undefined
  debugger_mode = true


  log = (msg) ->
    if debugger_mode
      console.log msg


  postUser = (expires_in, access_token) ->
    FB.api "/me", (res) ->
      user = {
        "name" : res.name,
        "email" : res.email,
        "fb_id" : res.id,
        "fb_expires_at" : expires_in,
        "fb_login_token" : fb_login_token,
        "fb_access_token" : access_token
      }
      req = jQuery.ajax
        url: "http://localhost:3000/shops/" + shop_id + "/users/"
        type: "POST"
        data: JSON.stringify(user)
        contentType: 'application/json'
        dataType: "json"
      req.done (msg) ->
        log "FB: User posted to the server"
      req.fail (jqXHR, textStatus) ->
        log "FB: post fallido: " + textStatus


  checkUserStatus = ->
    FB.getLoginStatus (response) ->
      if response.status is "connected"
        log "FB: user connected"
        postUser response.authResponse.expiresIn, response.authResponse.accessToken
      else if response.status is "not_authorized"
        log "FB: user not authorized"
      else
        log "FB: user not logued"


  login = ->
    FB.login ((response) ->
      checkUserStatus() if response.authResponse
    ), scope: "email"


  window.fbAsyncInit = ->
    FB.init
      appId: fb_app_id
      channelUrl: "//localhost:3000/channel.html"
      status: true
      cookie: true
      xfbml: true

    jQuery(document).ready ($) ->
      shop_id = $("#e-gamify-login").attr("s")
      fb_login_token = $("#e-gamify-login").attr("fb_lt")
      $("#e-gamify-fb-bt").click ->
        login()

      log "FB: Checking login status..."
      checkUserStatus()



  # Load the SDK Asynchronously
  ((d) ->
    log "FB: loading SDK..."
    js = undefined
    id = "facebook-jssdk"
    ref = d.getElementsByTagName("script")[0]
    return  if d.getElementById(id)
    js = d.createElement("script")
    js.id = id
    js.async = true
    js.src = "http://connect.facebook.net/en_US/all.js"
    ref.parentNode.insertBefore js, ref
  ) document

)()
