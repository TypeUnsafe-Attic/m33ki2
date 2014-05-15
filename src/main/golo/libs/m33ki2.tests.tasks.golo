module m33ki2.tests.tasks

import java.lang.Runnable

import m33ki2.tests.request

function RunnableTask = |request| {

  let conf = map[
    ["interfaces", ["java.lang.Runnable"]],
    ["implements", map[
      ["run", |this| {
        request: go()
      }]
    ]]
  ]
  return AdapterFabric(): maker(conf): newInstance()
}

function CallableTask = |request| {

  let conf = map[
    ["interfaces", ["java.util.concurrent.Callable"]],
    ["implements", map[
      ["call", |this| {
        request: go()
        return 42
      }]
    ]]
  ]
  return AdapterFabric(): maker(conf): newInstance()
}

function TaskObserver = |future, timeout| {

  let conf = map[
    ["interfaces", ["java.util.concurrent.Callable"]],
    ["implements", map[
      ["call", |this| {
        let start = System.currentTimeMillis()
        while not future: isDone() {

          if (System.currentTimeMillis() - start) > timeout {
            # TimeOut! then Cancel
            future: cancel(true)
            #println("Timeout! Then canceling ...")
          }
        }

      }]
    ]]
  ]
  return AdapterFabric(): maker(conf): newInstance()
}