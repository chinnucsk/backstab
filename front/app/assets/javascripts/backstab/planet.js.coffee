goog.provide("backstab.Planet")

goog.require('lime.Layer')
goog.require('lime.Circle')
goog.require('lime.Label')
goog.require('lime.animation.ColorTo')

class backstab.Planet
  constructor: (params) ->
    @neighbors = []
    @id = params[1].value
    @type = params[2].value
    @userId = params[3].value
    @quantity = params[4]
    @capacity = params[5]

  draw: ->
    planet = new lime.Layer().setPosition(@x, @y)
    circle = new lime.Circle().setSize(120, 120).setFill(255, 150, 0)
    base = undefined
    lbl = new lime.Label().setSize(160, 50).setFontSize(30).setText(@quantity)
    circle.appendChild lbl
    planet.appendChild circle
    planet.object = this
    @node = planet
    planet.showDropHighlight = ->
      circle.runAction new lime.animation.ColorTo(255, 198, 201).setDuration(.3)
    planet.hideDropHighlight = ->
      circle.runAction new lime.animation.ColorTo(255, 150, 0).setDuration(.1)
    planet

  @loadGraphics: ->
    ['ourship', 'enemyship'].forEach (e) ->
      i = new Image()
      i.src = "/assets/#{e}.png"
      backstab.Planet[e] = i
  @getBase64Image: (img) ->
    canvas = document.createElement("canvas")
    canvas.width = img.width
    canvas.height = img.height
    ctx = canvas.getContext("2d")
    ctx.drawImage(img, 0, 0)
    canvas.toDataURL("image/png")

  setQuantity: (val) ->
    @quantity = val
    return unless @node
    if @userId
      @baseNode.getChildAt(1).setText(val + '')
    @node.getChildAt(0).getChildAt(0).setText(val + '')

  setUser: (userId) ->
    if userId != @userId
      if @userId
        @baseNode.getParent().removeChild(@baseNode)
        @baseNode = null
      @userId = userId
      backstab.scene.appendChild @drawBase()

  drawBase: ->
    # create planetbase
    color = undefined
    fill = undefined
    if @userId == Userinfo.id
      color = "#798ee0"
      fill = backstab.Planet.getBase64Image(backstab.Planet.ourship)
    else
      color = "#c92020"
      fill = backstab.Planet.getBase64Image(backstab.Planet.enemyship)
    base = new lime.Sprite().setPosition(@node.getPosition()).setSize(140, 140).setFill(fill)
    handler = new lime.Sprite().setSize(base.getSize()).setFill(fill).setOpacity(.01)
    counterBg = new lime.Circle().setSize(50, 50).setFill(color)
    text = new lime.Label().setFontSize(30).setText(@quantity)
    base.appendChild counterBg
    base.appendChild text
    base.appendChild handler
    @baseNode = base
    # Drag army to another planet
    goog.events.listen handler, ["mousedown", "touchstart"], goog.bind((e) ->
      e.event.stopPropagation()
      handler.runAction new lime.animation.Spawn(new lime.animation.FadeTo(.8).setDuration(.2), new lime.animation.ScaleTo(1.3).setDuration(.2))
      drag = e.startDrag()
      @neighbors.forEach (planet) ->
        drag.addDropTarget planet.node
      goog.events.listen drag, lime.events.Drag.Event.CANCEL, ->
        handler.runAction new lime.animation.Spawn(new lime.animation.MoveTo(0, 0).setDuration(.2), new lime.animation.FadeTo(.01).setDuration(.2), new lime.animation.ScaleTo(1).setDuration(.2))
      goog.events.listen drag, lime.events.Drag.Event.DROP, goog.bind((e) ->
        #var dropTarget = e.activeDropTarget;
        backstab.send Bert.tuple(Bert.atom("goto"), [Bert.binary(@id + ""), Bert.binary(e.activeDropTarget.object.id + "")])
        e.stopPropagation()
        handler.runAction new lime.animation.Sequence(new lime.animation.Spawn(new lime.animation.FadeTo(.01).setDuration(.2), new lime.animation.ScaleTo(1).setDuration(.2)), new lime.animation.MoveTo(0, 0).setDuration(.1))
      , this)
    , this)
    base
