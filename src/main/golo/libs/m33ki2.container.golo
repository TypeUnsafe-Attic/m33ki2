module m33ki2.container


import java.util.concurrent.Executor
import java.util.concurrent.Executors

#import m33ki2.route
import m33ki2.router

import m33ki2.task.handler
import m33ki2.http.exchange

function Container = |router, server_executor| {

  let executor = server_executor orIfNull Executors.newCachedThreadPool()

  let conf = map[
    ["interfaces", ["org.simpleframework.http.core.Container"]],
    ["implements", map[
      ["handle", |this, request, response| {

        let currentRoute = router: getRoute(request: getMethod(), request: getPath(): toString())

        let http_exchange = httpExchange(
            request
          , response
          , currentRoute?: parameters()  orIfNull "n/a"
          , response:  getPrintStream()
          , null # transport value
          , null # data (content)
        )

        # TODO:
        # http://stackoverflow.com/questions/5116352/when-we-should-use-scala-util-dynamicvariable

        if not currentRoute is null {
          let task = Task(http_exchange, currentRoute: before(), currentRoute: do())
          executor: execute(task)
          # TODO: manage exception inside the task
        } else {
          let task = OtherTask(http_exchange, router: static())
          executor: execute(task)
          # TODO: manage exception inside the task
        }

      }]
    ]]
  ]

  return AdapterFabric(): maker(conf): newInstance()
}
