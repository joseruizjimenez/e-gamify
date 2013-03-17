(->

  fb_app_id = "451013134972296"
  e_gamify_domain = "localhost:3000"
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
        url: "http://"+e_gamify_domain+"/shops/" + shop_id + "/users/"
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
        $("#e-gamify-fb-bt").html "<a href='#'><img src='http://"+e_gamify_domain+"/widgets/img/fb_login.png'></img></a>"
        log "FB: user not authorized"
      else
        $("#e-gamify-fb-bt").html "<a href='#'><img src='http://"+e_gamify_domain+"/widgets/img/fb_login.png'></img></a>"
        log "FB: user not logued"


  login = ->
    FB.login ((response) ->
      checkUserStatus() if response.authResponse
    ), scope: "email"


  window.fbAsyncInit = ->
    FB.init
      appId: fb_app_id
      channelUrl: "//"+e_gamify_domain+"/channel.html"
      status: true
      cookie: true
      xfbml: true

    jQuery(document).ready ($) ->
      shop_id = $("#e-gamify-fb-login-token").attr("s")
      fb_login_token = $("#e-gamify-fb-login-token").attr("fb_lt")
      $("#e-gamify-fb-bt").html "<a href='#'><img src='http://"+e_gamify_domain+"/widgets/img/fb_login.png'></img></a>"
      $("#e-gamify-fb-bt").click ->
        login()
      log "FB: Ready to check login status..."



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
    js.src = "https://connect.facebook.net/es_ES/all.js"
    ref.parentNode.insertBefore js, ref
  ) document

)()
