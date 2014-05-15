module m33ki2.task.handler

import java.lang.Runnable
import m33ki2.http.exchange

function Task = |http_exchange, before_closure, do_closure| {

  let conf = map[
    ["interfaces", ["java.lang.Runnable"]],
    ["implements", map[
      ["run", |this| {
        if before_closure is null { do_closure(http_exchange) } else {
          if not before_closure(http_exchange) is false { do_closure(http_exchange) }
        }
      }]
    ]]
  ]
  return AdapterFabric(): maker(conf): newInstance()
}


function OtherTask = |http_exchange, staticFilesLocation| {

  let conf = map[
    ["interfaces", ["java.lang.Runnable"]],
    ["implements", map[
      ["run", |this| {

        http_exchange: serveStaticFiles(staticFilesLocation)

        # http_exchange: request(): getPath(): toString()
        #let body = http_exchange: response(): getPrintStream()
        #let time = System.currentTimeMillis()

        #http_exchange: response(): setValue("Content-Type", "text/plain")
        #http_exchange: response(): setDate("Date", time)
        #http_exchange: response(): setDate("Last-Modified", time)

        #body: println("Hello World : " + time)
        #body: close()

      }]
    ]]
  ]

  return AdapterFabric(): maker(conf): newInstance()
}