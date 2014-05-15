module stress.tests

import m33ki2.tests
import m33ki2.tests.request
import m33ki2.tests.tasks
import m33ki2.tests.loader

----
  js for parsing results
  var logs1 = results.logs.sort(function(a,b) { return a.time.start - b.time.start })

  logs1.forEach(function(record) {
    console.log(
      record.time.start,
      new Date(record.time.start),
      (new Date(record.time.start)).getMilliseconds(), "Duration :",
      record.time.end - record.time.start
    )
  })
----
function main = |args| {

  println("starting tests ...")

  # === TEST 1 : silly test ===
  loader(): timeout(2000_L)
    : stress(
      request(): http(): port(3000): host("localhost"): GET("/other")
        : check(|response| { # appends when always, check is not mandatory

          #if response: isRequestSuccessFull() is true { # else NullPointerException if non connected
          #  println(
          #    "Request n° " + response: requestId() +
          #    " -> duration : " + response: time(): duration() + " ms" +
          #    " " + response: code() + " " + response: message()
          #  )
          #}


          #if response: isRequestSuccessFull() is true {
          #
          #  if verify(): verbose(false): that(
          #    response: code(): shouldEqual(301) and
          #    response: message(): shouldEqual("OK")
          #  ) is true {
          #    # cool \o/
          #  }
          #}

        })
    )
    : done(|results| {
        println(results: reportName("Stress results : "): quickReport())

        println("All OK + 301 + < 2000 ms : ")
        println("-------------------------------------------")
        results: logs(): filter(|response| {
          return response : code(): shouldEqual(301) and
                 response: message(): shouldEqual("OK") and
                 response: time(): duration(): shouldBeLessOrEqualThan(2000_L)
        })
        : each(|response| {
            println("Request n° " + response: requestId() +" -> duration : " + response: time(): duration() + " ms")
        })
        println("===========================================")

        textToFile(JSON.stringify(results), "results01.json")


    })
    : run(15, results()) # 15 times

  # === TEST 2 : silly test ===

  loader(): timeout(2000_L)
    : scenario( # what to stress
      {
        return list[
            request(): http(): port(3000): host("localhost"): GET("/other")
          , request(): http(): port(3000): host("localhost"): GET("/other")
          , request(): http(): port(3000): host("localhost"): GET("/other")
          , request(): http(): port(3000): host("localhost"): GET("/other")
          , request(): http(): port(3000): host("localhost"): GET("/other")
        ]
      }
    )
    : done(|results| {
        println(results: reportName("*** Stress report : ***"): quickReport())
        textToFile(JSON.stringify(results), "report02.json")
    })
    : run(results())

  # === TEST 3 : silly test ===

  loader(): timeout(1500_L)
    : scenario( # what to stress
      {
        let requests = list[]

        10: times({
          requests: append(request(): http(): port(3000): host("localhost"): GET("/other"))
        })

        15: times({
          requests: append(request(): http(): port(3000): host("localhost"): GET("/movies"))
        })

        5: times({
          requests: append(request(): http(): port(3000): host("localhost")
            : POST("/user")
            : data("firstName=John&lastName=Doe")
            : check(|response| { # check is mandatory
                println("=============================")
                println(response)
                println("=============================")
              })
          )
        })

        return requests
      }
    )
    : done(|results| {
        println(results: reportName("Stress report : "): quickReport())
        textToFile(JSON.stringify(results), "report03.json")
    })
    : run(results())


}