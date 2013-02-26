(->

  jQuery = undefined
  user = undefined
  login_checks = 10

  login_token = ->
    return Math.random().toString(36).substr(2) + Math.random().toString(36).substr(2)


  fb_login_check = (shop, fb_login_token) ->
    jsonp_url = "http://localhost:3000/widgets/fb_check?s=" + shop +
      "&fb_lt=" + fb_login_token + "&callback=?"
    $.getJSON jsonp_url, (data) ->
      login_checks--
      user = data.json


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

      s = $("#e-gamify-main-bar").attr("shop")

      # SI HAY COOKIE (Y NO CADUCADA), SOLICITA /shops/:s/users/:user_id?s_token=:s_token
      # si es válido tendremos el usuario, sino:
      # SI NO HAY COOKIE O SESION COOKIE NO VALIDA: se pone lo de complemento fb_login

      fb_login_token = login_token()

      main_bar_html = "
        <h2 id='fb-bt'>hola</h2>
        <h2 id='e-gamify-status'>comprobando...</h2>
        <iframe src='http://localhost:3000/widgets/fb_login?s=" + s +
          "&fb_lt=" + fb_login_token + "'></iframe>
        "
      $("#e-gamify-main-bar").html main_bar_html

      # check fb login status each 2 seconds for 20 seconds
      checking = setInterval(fb_login_check(s, fb_login_token), 2000)
      while login_checks isnt 0 and (user is 'undefined' or user.id is 'undefined')
      clearInterval checking

      if user isnt 'undefined' and "id" in user
        # user loged in
        $("#e-gamify-status").html user.name + " logueado!!!"
      else
        # user not loged in
        $("#e-gamify-status").html "NO logueado"

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
