module m33ki2.http.exchange

import m33ki2.fs



# httpExchange structure
----

####Members

- `request` : `org.simpleframework.http.request`
- `response` : `org.simpleframework.http.response`
- `parameters` : contains uri parameters, ie `/user/{name}/{age}`
- `body` : `org.simpleframework.http.message.body`
- `transport` : only a field if you want propagate some value between closures with httpExchange object

----
struct httpExchange = {
    request
  , response
  , parameters
  , body
  , data # content
  , transport # exchange data between before_closure and do_closure
}


# httpExchange augmentations
----

####Helpers

- `getContentTypeOfFile(path)` return content type of a given path file
- `serveStaticFiles(staticFileLocation)` used to "serve" static assets

####CORS Support

- `allowCORS(origin, methods, headers)`

You can do that `$.get("http://localhost:3000/infos", function(data){console.log(data)})` from cross domain or `file:///` location

#####Use it

    appRouter
      : def(route(): GET("/infos"): do(|http| {
          http: allowCORS("*", "*", "*")
          http: json(
                  JSON. stringify(DynamicObject()
                      : firstName("Bob")
                      : lastName("Morane"))
              )
              : close()
      }))

####Body methods

- `println(content)` : `http: println(content)` is the same thing as `http: body(): println(content)`
- `close()` : `http: close()` is the same thing as `http: body(): close()`

####Response methods

- `content(content_type)` : ie: `http: content("application/json")` = `http: response(): setValue("Content-Type", "application/json")`
- `status(code)` : ie: `http: status(201)` = `this: response(): setValue("status", "201")`
- `json()` : set content type to "application/json"
- `json(content)` : set content type to "application/json" and send content to body
- `html()` : set content type to "text/html"
- `html(content)` : set content type to "text/html" and send content to body
- `text()` : set content type to "plain/text"
- `text(content)` : set content type to "plain/text" and send content to body
- `xml()` : set content type to "application/xml"
- `xml(content)` : set content type to "application/xml" and send content to body

####Important

httpExchange methods are fluent :

    http: html("<h1>Hello!</h1>"): status(200): close()

----
augment httpExchange {
  ----
  some comments ...
  ----
  function allowCORS = |this, origin, methods, headers| {
    this: response(): setValue("Access-Control-Allow-Origin", origin)
    this: response(): setValue("Access-Control-Request-Method", methods)
    this: response(): setValue("Access-Control-Allow-Headers", headers)
    return this
  }
  ----
  this is an other comment
  ----
  function println = |this, content| {
    this: data(content)
    #this: body(): println(content)
    return this
  }

  ----
  - `close()` : `http: close()` is the same thing as `http: body(): close()`
  ----
  function close = |this| {
    this: body(): println(this: data())
    this: body(): close()
    return this
  }

  function content = |this, contentType| {
    this: response(): setValue("Content-Type", contentType)
    return this
  }


  #import org.simpleframework.http$Status
  function status = |this, statusCode| {
    this: response(): setCode(statusCode)
    return this
  }
  ----
  hello
  ----
  function json = |this| {
    this: content("application/json")
    return this
  }
  function json = |this, content| {
    this: content("application/json")
    this: println(content)
    return this
  }
  ----
  ##JSONIZE
  ----
  function jsonize = |this, content| {
    this: content("application/json")
    this: println(JSON.stringify(content))
    return this
  }
  function html = |this| {
    this: content("text/html")
    return this
  }
  function html = |this, content| {
    this: content("text/html")
    this: println(content)
    return this
  }
  function text = |this| {
    this: content("text/plain")
    return this
  }
  function text = |this, content| {
    this: content("text/plain")
    this: println(content)
    return this
  }
  function xml = |this| {
    this: content("application/xml")
    return this
  }
  function xml = |this, content| {
    this: content("application/xml")
    this: println(content)
    return this
  }
  function getContentTypeOfFile = |this, path| {
    let filename = fileName(path)
    var mime = java.net.URLConnection.getFileNameMap():getContentTypeFor(filename)
    if mime is null {
      let which_content_type = |filename| -> match {
        when filename:contains(".htm")
          or filename:contains(".html")
          or filename:contains(".md")
          or filename:contains(".markdown")
          or filename:contains(".asciidoc")
          or filename:contains(".adoc") then "text/html;charset=UTF-8"
        when filename:contains(".css")
         or filename:contains(".less") then "text/css;charset=UTF-8"
        when filename:contains(".js")
          or filename:contains(".coffee")
          or filename:contains(".ts")
          or filename:contains(".dart")then "application/javascript;charset=UTF-8"
        when filename:contains(".json") then "application/json;charset=UTF-8"
        when filename:contains(".ico") then "image/x-ico"
        when filename:contains(".gif") then "image/gif"
        when filename:contains(".jpeg") or filename:contains(".jpg") then "image/jpeg"
        when filename:contains(".png") then "image/png"
        when filename:contains(".svg") then "image/svg+xml"
        when filename:contains(".eot") then "application/vnd.ms-fontobject"
        when filename:contains(".ttf") then "application/x-font-ttf"
        when filename:contains(".woff") then "application/x-font-woff"
        when filename:contains(".zip") then "application/zip"
        when filename:contains(".gz") then "application/gzip"
        when filename:contains(".pdf") then "application/pdf"
        when filename:contains(".xml") then "application/xml;charset=UTF-8"
        when filename:contains(".txt") then "text/plain;charset=UTF-8"
        otherwise "text/plain;charset=UTF-8"
      }
      mime = which_content_type(filename)
    }
    return mime
  }
  function serveStaticFiles = |this, staticFileLocation| {

    var requestPath = this: request(): getPath(): toString()
    if requestPath: equals("/") { requestPath = "/index.html"}
    let path = staticFileLocation + requestPath

    if fileExists(path) {
      let contentType = this: getContentTypeOfFile(path)
      #println("fileName : " + fileName(path) + " content-type : " + contentType)
      try {
        let text = fileToText(path, "UTF-8")
        this: content(contentType): status(200): println(text): close()
      } catch(e) {
        this: html("<b>500</b> : Huston we've got a problem!"): status(500): close()
      }
    } else {
      this: html("<b>404</b> : Oh Oh! Try Again!"): status(404): close()
    }
  }
}
