NAMESPACES =
  svg: 'http://www.w3.org/2000/svg'
  xlink: 'http://www.w3.org/1999/xlink'

CASE_SENSITIVE_ATTRIBUTES = [
  'viewBox'
]

FILTERS =
  shadow: [
    {element: 'feOffset', attributes: {in: 'SourceAlpha', dx: 0.5, dy: 1.5, result: 'offOut'}}
    {element: 'feBlend', attributes: {in: 'SourceGraphic', in2: 'offOut'}}
  ]

class SVG
  el: null

  constructor: (tagName, attributes) ->
    # Without a tag name, create an SVG container.
    [tagName, attributes] = ['svg', tagName] unless typeof tagName is 'string'

    # Classes can be assigned at creation: "circle.foo.bar".
    [tagName, classes...] = tagName.split '.'
    classes = classes.join ' '

    [namespace..., tagName] = tagName.split ':'
    namespace = namespace.join ''
    namespace ||= 'svg'

    @el = document.createElementNS NAMESPACES[namespace] || null, tagName

    @attr 'class', classes if classes
    @attr attributes

  attr: (attribute, value) ->
    # Given a key and a value:
    if typeof attribute is 'string'
      # Hyphenate camel-cased keys, unless they're case sensitive.
      unless attribute in CASE_SENSITIVE_ATTRIBUTES
        attribute = (attribute.replace /([A-Z])/g, '-$1').toLowerCase()

      [namespace..., attribute] = attribute.split ':'
      namespace = namespace.join ''

      @el.setAttributeNS NAMESPACES[namespace] || null, attribute, value

    # Given an object:
    else
      attributes = attribute
      @attr attribute, value for attribute, value of attributes

    null

  filter: (filter) ->
    @attr 'filter', if filter?
      "url(#marking-surface-filter-#{filter})"
    else
      ''

  addShape: (tagName, attributes) ->
    # Added shapes are automatically added as children, useful for SVG roots and groups.
    shape = new @constructor tagName, attributes
    @el.appendChild shape.el
    shape

  toFront: ->
    @el.parentNode.appendChild @el
    null

  remove: ->
    @el.parentNode.removeChild @el
    null

SVG.filtersContainer = new SVG
  id: 'marking-surface-filters-container'
  width: 0
  height: 0
  style: 'bottom: 0; position: absolute; right: 0;'

defs = SVG.filtersContainer.addShape 'defs'

SVG.registerFilter = (name, elements) ->
  FILTERS[name] = elements
  filter = defs.addShape 'filter', id: "marking-surface-filter-#{name}"
  filter.addShape element, attributes for {element, attributes} in elements
  null

SVG.registerFilter name, elements for name, elements of FILTERS

document.body.appendChild SVG.filtersContainer.el
