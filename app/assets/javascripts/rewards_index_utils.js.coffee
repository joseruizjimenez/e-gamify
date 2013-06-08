# Utils snippets for the main site, with coffee :)
# Remember: Coffe makes a clojure itself

$ = window.jQuery
Two = window.Two
touch_counter = 0
current_reward_hits = {}
img_to_change = undefined

draw_add_level = ->
  params = { width: 180, height: 230 }
  $('.two-canvas').each ()->
    canvas = $(this)[0]
    two = new Two(params).appendTo(canvas)
    line = two.makeLine(0, 140, 30, 140)
    line.stroke = "orange"
    line.linewidth = 3
    line.opacity = 0.60
    v_line = two.makeLine(60, 125, 60, 155)
    v_line.stroke = "orange"
    h_line = two.makeLine(45, 140, 75, 140)
    h_line.stroke = "orange"
    circle = two.makeCircle(60, 140, 30)
    circle.fill = 'rgb(255, 221, 161)'
    circle.stroke = 'orange'
    circle.linewidth = 3
    circle.opacity = 0.60
    two_circles.push(circle)
    two_groups.push(two.makeGroup(circle, v_line, h_line))
    two.update()
    two_instances.push(two)


darkerColor = (rgba_color)->
  darkenPercent = 15
  rgb = rgba_color.replace("rgba(", "").replace(")", "").split(",")
  red = $.trim(rgb[0])
  green = $.trim(rgb[1])
  blue = $.trim(rgb[2])
  red = parseInt(red * (100 - darkenPercent) / 100)
  green = parseInt(green * (100 - darkenPercent) / 100)
  blue = parseInt(blue * (100 - darkenPercent) / 100)
  "rgba(" + red + ", " + green + ", " + blue + ", " + rgb[3] + ")"


makeTriangle = (two, size) ->
  tri = two.makePolygon(-size / 2, 0, size / 2, 0, 0, size)
  tri


makeSun = (two) ->
  color = "rgba(255, 128, 0, 0.66)"
  sun = two.makeGroup()
  #radius = two.height / 4
  radius = 40
  #gutter = two.height / 20
  gutter = 8
  core = two.makeCircle(0, 0, radius)
  core.noStroke()
  core.fill = color
  sun.core = core
  coronas = []
  corona_amount = 16
  i = 0

  while i < corona_amount
    pct = (i + 1) / corona_amount
    theta = pct * Math.PI * 2
    x = (radius + gutter) * Math.cos(theta)
    y = (radius + gutter) * Math.sin(theta)
    corona = makeTriangle(two, gutter)
    corona.noStroke()
    corona.fill = color
    corona.translation.set x, y
    corona.rotation = Math.atan2(-y, -x) + Math.PI / 2
    coronas.push corona
    i++
  sun.add(core).add coronas
  sun.opacity = 0.85
  sun


draw_sun = ->
  increment = Math.PI / 256
  TWO_PI = Math.PI * 2

  params = { width: 250, height: 280 }
  $('.two-canvas').each ()->
    canvas = $(this)[0]
    two = new Two(params).appendTo(canvas)
    sun = makeSun(two)
    sun.translation.set(two.width / 2, two.height / 2)
    line = two.makeLine(0, two.height / 2, two.width / 2, two.height / 2)
    line.stroke = "rgb(255, 92, 0)"
    line.linewidth = 2
    line.opacity = 0.80

    sun.reward_node = $(this).attr "reward"
    sun.redeem_hits = $(this).attr("levels").split(',')
    .map (n)->
      parseInt n, 10
    current_reward_hits[sun.reward_node] = sun.redeem_hits
    sun.level_count = 0
    hits_input = $('#'+sun.reward_node).find("#reward_redeem_hits")
    hits_input.change ()->
      sun.redeem_hits[sun.level_count] = parseInt hits_input.val(), 10
      current_reward_hits[sun.reward_node] = sun.redeem_hits
    sun.domElement = $(this).find('#two-' + sun.id)
    sun.domElement.css('cursor', 'pointer')
    .click ()->
      hits_input = $('#'+sun.reward_node).find("#reward_redeem_hits")
      unless hits_input.val() is ''
        sun.level_count++
        hits_input.unbind 'change'
        hits_btn = $('#'+sun.reward_node).find(".btn-primary").first()
        if sun.redeem_hits.length <= sun.level_count
          hits_input.attr "value", ''
          hits_btn.text "Add!"
        else
          hits_input.attr "value", sun.redeem_hits[sun.level_count]
          hits_btn.text "Edit!"
        hits_input.change ()->
          if sun.redeem_hits.length <= sun.level_count
            sun.redeem_hits.push(parseInt(hits_input.val(), 10))
          else
            sun.redeem_hits[sun.level_count] = parseInt hits_input.val(), 10
          current_reward_hits[sun.reward_node] = sun.redeem_hits
        background = $('#'+sun.reward_node)
        darker_color = darkerColor background.css('background-color')
        background.css 'background-color', darker_color

    two.bind("resize", ->
      sun.translation.x = two.width / 2
      sun.translation.y = two.height / 2
      path.translation.copy sun.translation
    ).bind("update", (frameCount) ->
      sun.rotation = 0  if sun.rotation >= TWO_PI - 0.0125
      sun.rotation += (TWO_PI - sun.rotation) * 0.0125
    ).play()

    # TODO
    # implementar luna, metida en draw_sun. si es lvl 0 no hace nada, sino:
    #   disminuye color, el lvl. preguntar en boton solo por edit?


init_animation = ->
  two_instances[0].bind('update', (frameCount)->
    if two_circles[0].scale > 0.9999
      two_circles[0].scale = 0
    t = (1 - two_circles[0].scale) * 0.125
    two_circles[0].scale += t
  ).play()


scaleCircles = (scale)->
  two_circles.forEach (c)->
    c.scale = scale
  two_instances.forEach (i)->
    i.update()


# Some hotfixes for UI to work as desired on startup
$("#tab_new").removeClass("active")
$(".tab-pane").first().addClass("active")
$(".nav-tabs li").click ->
  choosen_id = $(this).find("a").attr("href").split('_')[1]
  if choosen_id is "new"
    $("#reward-id").html ""
  else
    $("#reward-id").html "Reward ID: <code>" + choosen_id + "</code>"

$(".choose-img").css('cursor', 'pointer')

$(".choose-img").click ->
  img_to_change = $(this).attr 'reward_id'
  $("#reward-images").modal('show')

$(".reward-img-thumbnail").css('cursor', 'pointer')

$(".reward-img-thumbnail").click ->
  if img_to_change is "new_img_uri"
    img_domElement = $(".reward-entry")
  else
    img_domElement = $("#tab_" + img_to_change)
  img_uri = $(this).attr('src')
  img_domElement.find("#reward_img_uri").attr 'value', img_uri
  img_domElement.find(".reward-img").attr 'src', img_uri
  $("#reward-images").modal('hide')

$(".btn_repeatable_true").click ->
  $(".reward_repeatable_" + $(this).attr("reward")).attr "value", "true"

$(".btn_repeatable_false").click ->
  $(".reward_repeatable_" + $(this).attr("reward")).attr "value", "false"

$(".btn_repeatable_true_new").click ->
  $(".reward_repeatable").attr "value", "true"

$(".btn_repeatable_false_new").click ->
  $(".reward_repeatable").attr "value", "false"

$("form").submit ()->
  has_update_field = $(this).find("input[name='_method']").length isnt 0
  if has_update_field
    reward_id = $(this).find(".reward-node").attr 'id'
    new_reward_hits = current_reward_hits[reward_id].join(',')
    $(this).find("#reward_redeem_hits").attr 'value', new_reward_hits
  return true


#draw_add_level()
draw_sun()
#init_animation()
