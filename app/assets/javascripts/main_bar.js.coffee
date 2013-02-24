(->

  jQuery = undefined

  # called once jquery has loaded
  scriptLoadHandler = ->
    # restore $ and window.jQuery to their previous values
    # and store the new jQuery in our local variable
    jQuery = window.jQuery.noConflict(true)
    main()


  main = ->
    jQuery(document).ready ($) ->
      # jquery is loaded
      style = $("#e-gamify-main-bar").attr("style")
      style = "classic" if style is `undefined`
      css_link = $("<link>",
        rel: "stylesheet"
        type: "text/css"
        href: "http://localhost:3000/assets/css/widgets/main_bar_" + style + ".css"
      )
      css_link.appendTo "head"

      s = $("#e-gamify-main-bar").attr("s_id")
      jsonp_url = "http://localhost:3000/widgets/main_bar?s=" + s + "&callback=?"
      # we can get data from the server
      $.getJSON jsonp_url, (data) ->
        $("#e-gamify-main-bar").html data.html


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
