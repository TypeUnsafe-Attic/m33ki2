module m33ki2.route

import m33ki2.uri.matcher

struct route = {
    method
  , uriTemplate
  , before
  , do #handle
  , parameters
}

# perhaps pass parameters to route constructor ? ie: authenticated

augment route {

  function GET = |this, uriTpl| {
    this: method("GET"): uriTemplate(uriTpl)
    return this
  }
  function POST = |this, uriTpl| {
    this: method("POST"): uriTemplate(uriTpl)
    return this
  }
  function PUT = |this, uriTpl| {
    this: method("PUT"): uriTemplate(uriTpl)
    return this
  }
  function DELETE = |this, uriTpl| {
    this: method("DELETE"): uriTemplate(uriTpl)
    return this
  }

  function matchWith = |this, strPath| { # request: getPath(): toString()
    return UriTemplate(this: uriTemplate()): matchString(strPath)
  }
}
