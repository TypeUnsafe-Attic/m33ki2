module functional.tests

import m33ki2.tests
import m33ki2.tests.request

function main = |args| {

  specification("Human model has a firstName, a lastName and a toString method", [
    -> requirement("firstName = John and lastName = Doe", {
        let john = models.humans.Human("John", "Doe")
        verify(): that(
          john: firstName(): shouldEqual("John") and john: lastName(): shouldEqual("Doe")
        )
    })
    ,
    -> requirement("john: firstName = John and john: lastName = Doe, then john: toString() = John Doe ", {
        let john = models.humans.Human("John", "Doe")
        verify(): that(
          john: toString(): shouldEqual("John Doe")
        )
    })
  ])

  readln("Verify if server is listening ... then press enter")

  specification("Get requests", [
    -> requirement("http://localhost:3000/others -> code = 301 message=OK and it's Bob Morane", {
        request(): http(): port(3000): host("localhost"): GET("/other")
          : success(|response| {
              verify(): that("code is 301 and message is OK",
                response: code(): shouldEqual(301) and
                response: message(): shouldEqual("OK")
              )
              verify(): that("I've got Bob Morane and this is json",
                response: text(): trim(): shouldEqual("{\"firstName\":\"Bob\",\"lastName\":\"Morane\"}") and
                response: contentType(): shouldEqual("application/json")
              )
          })
          : fail(|response, err| {})
          : always(|response| {
              println("  Duration : " + response: time(): duration() + " ms")
          })
          : go()
    })
    ,
    -> requirement("http://localhost:3000 -> this is the Home", {
        request(): http(): port(3000): host("localhost"): GET("/")
          : success(|response| {
              verify(): that("code is 200 and message is OK",
                response: code(): shouldEqual(200) and
                response: message(): shouldEqual("OK")
              )
              verify(): that("this is html",
                response: contentType(): shouldEqual("text/html")
              )
          })
          : fail(|response, err| {})
          : always(|response| {
              println("  Duration : " + response: time(): duration() + " ms")
          })
          : go()
    })
  ])

  specification("Post requests", [
    -> requirement("http://localhost:3000/user -> post return message with smiley and code is 201", {
        request(): id(1212): http(): port(3000): host("localhost"): POST("/user")
          : data("{\"firstName\":\"John\",\"lastName\":\"Doe\"}")
          : success(|response| {
              verify(): that("code is 201 and message is OK",
                response: code(): shouldEqual(201) and
                response: message(): shouldEqual("OK")
              )
              verify(): that("this is json",
                response: contentType(): shouldEqual("application/json")
              )

              verify(): that("content message contains a smiley",
                response: text(): contains(":)"): shouldEqual(true)
              )

              verify(): that("content message not contains a sad smiley",
                response: text(): contains(":("): shouldNotEqual(true)
              )
          })
          : fail(|response, err| {})
          : always(|response| {
              println("  (" + response: requestId() + ") Duration : " + response: time(): duration() + " ms")
          })
          : go()
    })

  ])


}