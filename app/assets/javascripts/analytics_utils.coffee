# Utils snippets for the main site, with coffee :)
# Remember: Coffe makes a clojure itself

$ = window.jQuery

setTimeout () ->
  $(".graph-tab").removeClass "active"
  $("#tab_1").addClass "active"
, 20
