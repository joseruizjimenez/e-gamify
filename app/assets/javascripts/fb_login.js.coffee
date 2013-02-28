(->

  login = ->
    FB.login ((response) ->
      if response.authResponse
        # connected
        FB.api "/me", (response) ->
          alert "hola " + response.email
      else
        alert "nada"
    ),
      scope: "email"


  testAPI = ->
    console.log "Welcome!  Fetching your information.... "
    FB.api "/me", (response) ->
      console.log "Good to see you, " + response.name + "."


  window.fbAsyncInit = ->
    FB.init
      appId: "451013134972296"
      channelUrl: "//localhost:3000/channel.html"
      status: true
      cookie: true
      xfbml: true


    FB.getLoginStatus (response) ->
      # SI ESTA LOGUEADO Y AUTORIZADO
      jQuery(document).ready ($) ->
        $("#fb-bt").click ->
          login()

        if response.status is "connected"
          s = $("#e-gamify-login").attr("s")
          fb_login_token = $("#e-gamify-login").attr("fb_lt")

          FB.api "/me", (res) ->
            user = {
              "name" : res.name,
              "email" : res.email,
              "fb_id" : res.id,
              "fb_expires_at" : response.authResponse.expiresIn,
              "fb_login_token" : fb_login_token,
              "fb_access_token" : response.authResponse.accessToken
            }
            req = $.ajax
              url: "http://localhost:3000/shops/"+s+"/users/"
              type: "POST"
              data: JSON.stringify(user)
              contentType: 'application/json'
              dataType: "json"

            req.done (msg) ->
              # user fetch OK

            req.fail (jqXHR, textStatus) ->
              console.log "post fallido: " + textStatus

        # SINO...
        else if response.status is "not_authorized"
          #login()
          console.log "no autorizado"
        else
          #login()
          console.log "no logueado en fb"


  # Load the SDK Asynchronously
  ((d) ->
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
