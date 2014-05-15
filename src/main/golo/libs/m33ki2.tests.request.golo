module m33ki2.tests.request

struct options = { protocol, host, port, path, encoding, userAgent, contentType, requestMethod, data }
struct callbacks = { success, fail, always }

struct delay = {
  start,
  end
}

augment delay {

  function duration = |this| -> this: end() - this: start()
}

struct response = {
  headers,
  body,
  code,
  message,
  text,
  encoding,
  contentType,
  time,
  requestId,
  isRequestSuccessFull,
  isRequestFailed
}
# , contentLoaded, ...
# http://docs.oracle.com/javase/7/docs/api/java/net/URLConnection.html

struct request = {
  protocol,
  port,
  host,
  encoding,
  path,
  requestMethod,
  success,
  fail,
  always,
  isSuccessFull,
  isFailed,
  check, # used for stress test
  data,
  id # useful if several request

}

# let port = this: port() orIfNull 443

augment request {

  function getOrDeleteRequest = |this, options, callbacks| {
    let resp = response()
    let protocol = options: protocol() orIfNull "http"
    let port = options: port() orIfNull 80
    #TODO: test host and path
    let url = protocol+"://"+options: host()+":"+port+options: path()

    resp: time(delay(System.currentTimeMillis(), null))
    resp: requestId(this: id())

    try {
      let obj = java.net.URL(url) # URL obj
      let con = obj: openConnection() # HttpURLConnection con (Cast?)
      #optional default is GET
      con: setRequestMethod(options: requestMethod() orIfNull "GET")

      let contentType = options: contentType() orIfNull "text/plain; charset=utf-8"
      con: setRequestProperty("Content-Type", contentType)

      #add request header
      let userAgent = options: userAgent() orIfNull "Mozilla/5.0"
      con: setRequestProperty("User-Agent", userAgent)

      resp: code(con: getResponseCode()) # int responseCode
      resp: message(con: getResponseMessage()) # String responseMessage

      #http://docs.oracle.com/javase/7/docs/api/java/net/URLConnection.html
      resp: headers(con: getHeaderFields())
      resp: encoding(con: getContentEncoding())
      resp: contentType(con: getContentType())

      let encoding = options: encoding() orIfNull "UTF-8"

      #println("encoding " + encoding)

      resp: text(java.util.Scanner(con: getInputStream(), encoding):useDelimiter("\\A"):next()) # String responseText

      resp: time(): end(System.currentTimeMillis())

      let success = callbacks: success()
      if success isnt null {
        success(resp)
      }
      this: isSuccessFull(true)
      this: isFailed(false)
      resp: isRequestSuccessFull(true)
      resp: isRequestFailed(false)

    } catch(e) {
      this: isSuccessFull(false)
      this: isFailed(true)

      resp: isRequestSuccessFull(false)
      resp: isRequestFailed(true)

      let fail = callbacks: fail()
      if fail isnt null { fail(resp, e) } else { raise("Huston, we've got a problem", e) }
    } finally {
      let always = callbacks: always()
      if always isnt null {
        always(resp)
      }
    }
  }

#import java.io.BufferedReader;
#import java.io.DataOutputStream;
#import java.io.InputStreamReader;
#import java.net.HttpURLConnection;
#import java.net.URL;

# http://www.mkyong.com/java/how-to-send-http-request-getpost-in-java/
  function postOrPutRequest = |this, options, callbacks| {
    let resp = response()
    let protocol = options: protocol() orIfNull "http"
    let port = options: port() orIfNull 80
    #TODO: test host and path
    let url = protocol+"://"+options: host()+":"+port+options: path()

    resp: time(delay(System.currentTimeMillis(), null))
    resp: requestId(this: id())

    try {
      let obj = java.net.URL(url) # URL obj
      let con = obj: openConnection() # HttpURLConnection con (Cast?)
      #optional default is POST
      con: setRequestMethod(options: requestMethod() orIfNull "POST")

      #add request header
      let userAgent = options: userAgent() orIfNull "Mozilla/5.0"
      con: setRequestProperty("User-Agent", userAgent)

      #println(con: getRequestMethod())
      #http://www.xyzws.com/Javafaq/how-to-use-httpurlconnection-post-data-to-web-server/139

      #let contentType = options: contentType() orIfNull "text/plain; charset=utf-8"
      #con: setRequestProperty("Content-Type", contentType)
      #con.setRequestProperty("Accept-Language", "en-US,en;q=0.5")
      #con.setRequestProperty("Content-Language", "en-US")

      #con: setRequestProperty("Content-Type", "application/x-www-form-urlencoded")

      #con: setRequestProperty("Content-Type", "application/json")

      con: setRequestProperty("Content-Length", "" +
                     java.lang.Integer.toString(options: data(): getBytes(): length()))


      #add request header
      #let userAgent = options: userAgent() orIfNull "Mozilla/5.0"
      #con: setRequestProperty("User-Agent", userAgent)

      # Send post request
      #con: setUseCaches (false)
      #con: setDoInput(true)
      con: setDoOutput(true)


      let wr = java.io.DataOutputStream(con: getOutputStream())

      #println("pour test : post data : " + options: data())
      #InputStreamReader in = new InputStreamReader((InputStream) conn.getContent(), "utf-8");
      #java.net.URLDecoder.decode(inputLine, "UTF-8");

      wr: writeBytes(options: data())
      #wr: writeBytes("sn=C02G8416DRJM&cn=&locale=&caller=&num=12345")
      wr: flush()
      wr: close()

      #con: disconnect()

      # Get Response
      resp: code(con: getResponseCode()) # int responseCode
      resp: message(con: getResponseMessage()) # String responseMessage

      #http://docs.oracle.com/javase/7/docs/api/java/net/URLConnection.html
      resp: headers(con: getHeaderFields())
      resp: encoding(con: getContentEncoding())
      resp: contentType(con: getContentType())

      let encoding = options: encoding() orIfNull "UTF-8"

      #println("encoding " + encoding)

      resp: text(java.util.Scanner(con: getInputStream(), encoding):useDelimiter("\\A"):next()) # String responseText

      resp: time(): end(System.currentTimeMillis())

      let success = callbacks: success()
      if success isnt null {
        success(resp)
      }
      this: isSuccessFull(true)
      this: isFailed(false)

    } catch(e) {
      this: isSuccessFull(false)
      this: isFailed(true)
      let fail = callbacks: fail()
      if fail isnt null { fail(resp, e) } else { raise("Huston, we've got a problem", e) }
    } finally {
      let always = callbacks: always()
      if always isnt null {
        always(resp)
      }
    }
  }


  function http = |this| {
    this: protocol("http")
    return this
  }

  function https = |this| {
    this: protocol("https")
    return this
  }

  function GET = |this, url| {
    this: requestMethod("GET")
    this: path(url)
    return this
  }

  function POST = |this, url| {
    this: requestMethod("POST")
    this: path(url)
    return this
  }

  function go = |this| {
    if "GET": equals(this: requestMethod()) {
      this: getOrDeleteRequest(
        options()
          : protocol(this: protocol()): host(this: host()): port(this: port())
          : requestMethod(this: requestMethod())
          : path(this: path())
          : encoding(this: encoding()),
        callbacks()
          : success(this: success())
          : fail(this: fail())
          : always(this: always())
      )
      return this
    }
    if "POST": equals(this: requestMethod()) {
      this: postOrPutRequest(
        options()
          : protocol(this: protocol()): host(this: host()): port(this: port())
          : requestMethod(this: requestMethod())
          : path(this: path())
          : encoding(this: encoding())
          : data(this: data()),
        callbacks()
          : success(this: success())
          : fail(this: fail())
          : always(this: always())
      )
      return this
    }


  }

}