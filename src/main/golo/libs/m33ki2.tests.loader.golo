module m33ki2.tests.loader

#import java.util.concurrent.Executor
import java.util.concurrent.Executors
import java.util.concurrent.Semaphore
import java.util.concurrent.TimeUnit

import java.util.concurrent.atomic.AtomicInteger

import m33ki2.tests
import m33ki2.tests.tasks
import m33ki2.tests.request

augment java.lang.String {
  # interpolate
	function T = |this, dataName, data| {
		let tpl = gololang.TemplateEngine()
							: compile("<%@params "+dataName+" %> "+this)
		return tpl(data)
	}
}

augment java.util.concurrent.Semaphore {
  function protect = |this, somethingToCompute| { #restrict
    this: acquire()
    somethingToCompute()
    this: release()
  }
}

function getSemaphore = |arg| -> java.util.concurrent.Semaphore(arg)

augment request.types.request {
  function hello = |this| {
    println("hello")
    return this
  }

}

struct results = {
  logs,
  count,
  howMany,
  start,
  end,
  duration,
  countFail,
  countSuccess,
  reportName
}

augment results {
  function hello = |this| -> "hello"

  function quickReport = |this| -> """
===========================================
<%= results: reportName() %>
-------------------------------------------
Total : <%= results: howMany() %> requests during <%= results: duration() %> ms
Success : <%= results: countSuccess() %>
Fail (exception) : <%= results: countFail() %>
Timeout : <%= results: logs(): count(|response| -> response: message() is null) %>
==========================================="""
:T("results", this)

}

struct loader = {
  executor,
  scheduledExecutor,
  timeout,
  stress, # request
  done # callback
}

#TODO: see http://docs.oracle.com/javase/7/docs/api/java/util/concurrent/atomic/AtomicInteger.html
augment loader {

  function run = |this, how_many, results_loader| {
    this: executor(Executors.newCachedThreadPool()) # todo: add parameter

    results_loader: start(System.currentTimeMillis())
    results_loader: howMany(how_many)

    results_loader: count(0)
    results_loader: countSuccess(0)
    results_loader: countFail(0)

    results_loader: logs(list[]) # concurrentList?

    let request = this: stress()

    let protector_always = getSemaphore(1)
    let protector_success = getSemaphore(1)
    let protector_fail = getSemaphore(1)

    request: success(|response| {
      protector_success: protect({
        results_loader: countSuccess(results_loader: countSuccess() + 1)
      })

    })

    request: fail(|response, err| {
      #response: code(666): message("Huston? We've got a problem!")
      response: code(666): message(err: getMessage()): text(null)

      # message : Connection refused, -> pas de connexion
      # si message null : TimeOut (probablement)

      protector_fail: protect({
        results_loader: countFail(results_loader: countFail() + 1)
      })
    })

    request: always(|response| {
      #try {
      #  println(response)
      #} catch (e) {
      #  println(e)
      #}
      # java.lang.NullPointerException if not connected
      protector_always: protect({
        try {
          # count all tasks
          results_loader: count(results_loader: count() + 1)

          response: requestId(results_loader: count())

          #response: requestId(request: id())

          results_loader: logs(): add(response)

          if not request: check() is null { request: check()(response) } # after ?


          if results_loader: count(): equals(results_loader: howMany()) {
            # we're done
            results_loader: end(System.currentTimeMillis())
            results_loader: duration(results_loader: end() - results_loader: start())

            this: done()(results_loader)
            this: executor(): shutdown()

          }
        } catch (e) {
            println(e)
            # this: executor(): shutdown()
        }
        # finally {
        #
        #}

      })

    })

    how_many: times(|taskNumber| {
      #this: _executor(): execute(Task(request))
      #request: id(taskNumber)
      let future = this: executor(): submit(CallableTask(request))
      # cancel if time-out
      this: executor(): submit(TaskObserver(future, this: timeout()))

    })

    return this
  }

  function scenario = |this, closureScenario| {
    this: stress(closureScenario)
    return this
  }

  function run = |this, results_loader| {
    this: executor(Executors.newCachedThreadPool()) # todo: add parameter



    results_loader: count(0)
    results_loader: countSuccess(0)
    results_loader: countFail(0)

    results_loader: logs(list[]) # concurrentList?

    let requests = this: stress()()

    results_loader: start(System.currentTimeMillis())

    results_loader: howMany(requests: size())

        let protector_always = getSemaphore(1)
        let protector_success = getSemaphore(1)
        let protector_fail = getSemaphore(1)

    try {
      requests: each(|request| {
        #println("==>")


        request: success(|response| {
          protector_success: protect({
            results_loader: countSuccess(results_loader: countSuccess() + 1)
          })
        })

        request: fail(|response, err| {
          response: code(666): message(err: getMessage()): text(null)
          protector_fail: protect({
            results_loader: countFail(results_loader: countFail() + 1)
          })
        })

        request: always(|response| {

          protector_always: protect({
            try {
              # count all tasks
              results_loader: count(results_loader: count() + 1)
              response: requestId(results_loader: count())
              #response: requestId(request: id())
              results_loader: logs(): add(response)

              if not request: check() is null { request: check()(response) } # after ?

              if results_loader: count(): equals(results_loader: howMany()) {
                # we're done
                results_loader: end(System.currentTimeMillis())
                results_loader: duration(results_loader: end() - results_loader: start())

                this: done()(results_loader)
                this: executor(): shutdown()

              }
            } catch (e) {
                println(e)
                # this: executor(): shutdown()
            }
          }) # end protector
        })

        let future = this: executor(): submit(CallableTask(request))
        this: executor(): submit(TaskObserver(future, this: timeout()))
      })
    } catch (e) {
      println(e)
    }

    return this
  }


}



