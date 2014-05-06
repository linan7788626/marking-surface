class Tool extends SVG
  @Mark: Mark
  @Controls: null
  @mobile: !!navigator.userAgent.match /iP|droid/

  tag: 'g.marking-surface-tool'

  markingSurface: null

  movements: 0

  constructor: ->
    super

    unless @mark?
      @mark = new @constructor.Mark

    @mark.on 'change', [@, 'onMarkChange']
    @mark.on 'destroy', [@, 'destroy']

    @focusTarget = new ToolFocusTarget
      tool: this

    @controls = if @constructor.Controls?
      controls = new @constructor.Controls
        tool: this

    @focusRoot = SVG::addShape.call @, 'g.marking-surface-tool-focus-root'
    @selectedRoot = @focusRoot.addShape 'g.marking-surface-tool-selected-root'
    @root = @selectedRoot.addShape 'g.marking-surface-tool-root'

  setMarkingSurface: (@markingSurface) ->
    unless this in @markingSurface.tools
      @remove()
      @markingSurface.addTool this

    @rescale @markingSurface.getScale()

  onMarkChange: (property, value) ->
    @render? property, value # render: (property, value) -> swith property...
    @render?[property]?.call? @, value # render: x: (x) -> @move x
    @[@render?[property]]?() # render: x: 'move'
    @trigger 'change', [@mark]

  addShape: ->
    @root.addShape arguments...

  coords: (e) ->
    @markingSurface.toScale @markingSurface.sizeRect.pointerOffset e

  _onStart: (e) ->
    e.preventDefault()
    @select()
    super

  handleEvent: ->
    unless @disabled or @markingSurface.disabled
      super

  # NOTE: These "initial" events originate on the marking surface.

  onInitialStart: (e) ->
    @select()
    @trigger 'initial-click', [e]

  onInitialMove: (e) ->
    @trigger 'initial-drag', [e]

  onInitialRelease: (e) ->
    @movements += 1
    @trigger 'initial-release', [e]

  rescale: (scaleX, scaleY) ->
    @render()

  render: ->
    # TODO

  isComplete: ->
    # Override this if drawing the tool requires multiple drag steps (e.g. axes).
    @movements is 1

  focus: ->
    @attr 'data-focused', true
    @trigger 'focus'

  blur: ->
    @attr 'data-focused', null
    @trigger 'blur'

  select: ->
    @focus()
    @attr 'data-selected', true
    @toFront()
    @trigger 'select'

  deselect: ->
    @attr 'data-selected', null
    @trigger 'deselect'

  destroy: ->
    @deselect()
    super

Tool.defaultStyle = insertStyle 'marking-surface-tool-default-style', """
  .marking-surface-tool[data-focused] .marking-surface-tool-focus-root {
    filter: url(##{FILTER_ID_PREFIX}focus);
  }

  .marking-surface-tool[data-selected] .marking-surface-tool-selected-root {
    filter: url(##{FILTER_ID_PREFIX}shadow);
  }
"""
