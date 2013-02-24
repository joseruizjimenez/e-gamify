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


$("#fb-bt").click ->
  login()


testAPI = ->
  console.log "Welcome!  Fetching your information.... "
  FB.api "/me", (response) ->
    console.log "Good to see you, " + response.name + "."


window.fbAsyncInit = ->
  FB.init
    appId: "451013134972296"
    channelUrl: "//localhost/channel.html"
    status: true
    cookie: true
    xfbml: true

  FB.getLoginStatus (response) ->
    if response.status is "connected"
      alert "usuario logueado"
    else if response.status is "not_authorized"
      #login()
    else
      #login()


# Load the SDK Asynchronously
((d) ->
  js = undefined
  id = "facebook-jssdk"
  ref = d.getElementsByTagName("script")[0]
  return  if d.getElementById(id)
  js = d.createElement("script")
  js.id = id
  js.async = true
  js.src = "//connect.facebook.net/en_US/all.js"
  ref.parentNode.insertBefore js, ref
) document
