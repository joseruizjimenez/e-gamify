(->

  jQuery = undefined
  user = undefined
  login_checks = 5
  checking = undefined

  login_token = ->
    return Math.random().toString(36).substr(2) + Math.random().toString(36).substr(2)


  # fb_login_check = (shop, fb_login_token) ->
  #   console.log "login checks: " + login_checks
  #   jsonp_url = "http://localhost:3000/widgets/fb_check?s=" + shop +
  #     "&fb_lt=" + fb_login_token + "&callback=?"
  #   jQuery.getJSON jsonp_url, (data) ->
  #     login_checks--
  #     console.log "login checks: " + login_checks
  #     if (login_checks <= 0 or (user isnt undefined and user.id isnt undefined))
  #       console.log "login checks: " + login_checks
  #       window.clearInterval(checking)
  #     console.log data
  #     user = data


  # called once jquery has loaded
  scriptLoadHandler = ->
    # restore $ and window.jQuery to their previous values
    # and store the new jQuery in our local variable
    jQuery = window.jQuery.noConflict(true)
    main()


  main = ->
    jQuery(document).ready ($) ->
      # load css
      style = $("#e-gamify-main-bar").attr("style")
      style = "classic" if style is `undefined`
      css_link = $("<link>",
        rel: "stylesheet"
        type: "text/css"
        href: "http://localhost:3000/widgets/css/main_bar/" + style + ".css"
      )
      css_link.appendTo "head"

      shop_id = $("#e-gamify-main-bar").attr("shop")

      # SI HAY COOKIE (Y NO CADUCADA?), SOLICITA /shops/:s/users/:user_id?s_token=:s_token
      #   en servidor, si  ese s_token no coincide (o caducado) en la query es que ha de reloguearse
      # si es válido tendremos el usuario, sino:
      # SI NO HAY COOKIE O SESION COOKIE NO VALIDA: se pone lo de complemento fb_login

      fb_login_token = login_token()

      main_bar_html = "
        <h2 id='fb-bt'>hola</h2>
        <h2 id='e-gamify-status'>comprobando...</h2>
        <iframe src='http://localhost:3000/widgets/fb_login?s=" + shop_id +
          "&fb_lt=" + fb_login_token + "'></iframe>
        "
      $("#e-gamify-main-bar").html main_bar_html

      updateUserStatus = (logued_user) ->
        if logued_user isnt undefined
          # user loged in
          $("#e-gamify-status").html logued_user.name + " logueado!!!"
          $("#e-gamify-status").append "<img src='https://graph.facebook.com/" + logued_user.fb_id + "/picture'>"
          # PONER DATOS USUARIO EN COOKIE CON BASE64......
        else
          # user not loged in
          $("#e-gamify-status").html "NO logueado"

      # check fb login status each 2 seconds for 20 seconds
      jsonp_url = "http://localhost:3000/widgets/fb_check?s=" + shop_id +
        "&fb_lt=" + fb_login_token + "&callback=?"
      checking = setInterval () ->
        if (login_checks < 0 or (user isnt undefined and user.id isnt undefined))
          clearInterval checking
          updateUserStatus(user)
        else
          login_checks--
          jQuery.getJSON jsonp_url, (data) ->
            user = data
      , 2000



      ### load data
      s = $("#e-gamify-main-bar").attr("s_id")
      jsonp_url = "http://localhost:3000/widgets/main_bar?s=" + s + "&callback=?"
      # we can get data from the server
      $.getJSON jsonp_url, (data) ->
        $("#e-gamify-main-bar").append data.html
      ###

      $("#fb-bt").click ->
        ## ABRIMOS VENTANA MODAL CON IFRAME fb api y .login del tiron
        ## seguido de otro periodo de checkeo, esta vez mas largo (o con campo de check)
        alert "FB button"


  if window.jQuery is `undefined` or window.jQuery.fn.jquery isnt ("1.9.1" or "1.9.0" or
        "1.8.3" or "1.8.2" or "1.8.1" or "1.8.0" or "1.7.2" or "1.7.1" or "1.7.0" or
        "1.6.4" or "1.6.3" or "1.6.2" or "1.6.1" or "1.6.0")
    script_tag = document.createElement("script")
    script_tag.setAttribute "src", "http://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"
    script_tag.setAttribute "type", "text/javascript"
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
    main()

)()
