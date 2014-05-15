module m33ki2.router

import m33ki2.route

struct router = {
    routes # this is a list
  , static
}

augment router {
  function def = |this, route_or_routes| {
    if route_or_routes oftype gololang.Tuple.class {
      route_or_routes: each(|route| {
        this: routes(): add(route)
      })
    } else {
      this: routes(): add(route_or_routes)
    }
    return this
  }

  #todo : remove

  function getRoute = |this, method, uri| {
    let filteredRoutesWithMethod = this: routes()
      : filter(|route| {
        return method: equals(route: method())
      })

    let filteredRoutesWithMethodCopy = list[]
    filteredRoutesWithMethodCopy: addAll(filteredRoutesWithMethod)

    let similarRoutes = filteredRoutesWithMethodCopy: filter(|route| {
      let variables = route: matchWith(uri) # variables: get(variables: size())
      route: parameters(variables)
      return not variables: get(variables: size() - 1) is null
    })
    # (max of variables: size())

    let v = vector[null]
    similarRoutes: reduce(0, |acc, next| {
      if next: parameters(): size() > acc {
        v: set(0,next)
      }
      return next: parameters(): size()
    })
    let currentRoute = v: get(0) # get the route with max parameters

    return currentRoute
  }
}


function Router = {
  let appRouter = router(): routes(list[])

  return appRouter
}