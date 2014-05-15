module main

# proof of concept
import m33ki2.route
import m33ki2.router
import m33ki2.server
import m33ki2.http.exchange
import m33ki2.fs

#import org.simpleframework.http.Status

augment java.util.ArrayList {
  function extract = |this, start, end| {
    if this: size() < (end - start) {
      return this: subList(start, this: size())
    } else {
      return this: subList(start, end)
    }
  }
}


function main = |args| {

  let appRouter = Router(): static(currentWorkingDirectory() + "/public")
  let moviesList = fileToText(currentWorkingDirectory() + "/json/movies.json", "UTF-8")
  let jsonMoviesList = JSON.parse(moviesList)

  appRouter: def([
    route(): GET("/hello"): do(|http| {
      http: text()
          : println("parameters : " + http: parameters())
          : close()
    })
    ,
    route(): GET("/hello/{name}/{home}"): do(|http| {
      http: text("parameters : " + http: parameters()): close()
    })
    ,
    route(): GET("/hello/{name}"): do(|http| {
      http: text("parameters : " + http: parameters())
          : close()
    })
    ,
    route(): GET("/about"): do(|http| {
      http: html("<h1>Hello</h1><h2>World</h2><h3>!!!</h3>")
          : close()
    })
    ,
    route(): GET("/infos"): do(|http| {
      http: allowCORS("*", "*", "*")
      http: json(
        JSON. stringify(DynamicObject()
            : firstName("Bob")
            : lastName("Morane"))
      ): close()
    })
    ,
    route(): GET("/other"): do(|http| {
      # for the stress tests
      java.lang.Thread.sleep( java.util.Random(): nextInt(5) * 1000_L )
      http: json(
        JSON. stringify(DynamicObject()
            : firstName("Bob")
            : lastName("Morane"))
      ): status(301): close()
    })
    ,
    route(): GET("/movies"): do(|http| {
      http: json(moviesList): close()
    })
    ,
    route(): GET("/movies/search/genre/{genre}/{limit}"): do(|http| {
      let genre = http: parameters(): get("genre"): toLowerCase() #todo: shortcut : http: parameter("genre")
      let limit = http: parameters(): get("limit"): toInteger()

      let res = jsonMoviesList: filter(|movie| {
        return movie: get("Genre"): toString(): toLowerCase(): contains(genre)
      }): extract(0, limit)

      http: json(JSON.stringify(res)): close()
    })
    ,
    route(): GET("/before/{value}"): before(|http| {
      let value = http: parameters(): get("value")
      if not "ok": equals(value) {
          http: html("<h1>FORBIDDEN!</h1>"): close()
          return false # mandatory to prevent next closure do()
      }
    })
    : do(|http| {
        http: html("<h1>WELCOME!</h1>"): close()
    })
    ,
    route(): POST("/user"): do(|http|{

      let data = http: request(): getQuery() # do a shortcut in httpExchange + a "fromJson"

      println(data)
      println(data: get("firstName"))

      http: jsonize(map[["message","OK :)"]]): status(201): close()

    })

  ])

  #Add routes
  let thisIsMyFirstRoute = route(): GET("/one") :do(|http| -> http: text("one"): close())
  let thisIsMySecondRoute = route(): GET("/two") :do(|http| -> http: text("two"): close())

  appRouter: def([thisIsMyFirstRoute, thisIsMySecondRoute])

  server(): port(3000): router(appRouter): start()
  #add ability to change executor (of container) : as a parameter of server
  #server(): port(3000): router(appRouter): executor(java.util.concurrent.Executors.newFixedThreadPool(10)): start()


}

