module m33ki2.server

import java.net.InetSocketAddress
import org.simpleframework.http.core.ContainerServer
import org.simpleframework.transport.connect.SocketConnection

import m33ki2.container

struct server = {
    port
  , router
  , executor
}

augment server {

  function start = |this| {
    let container = Container(this: router(), this: executor())
    let containerServer = ContainerServer(container)
    let connection = SocketConnection(containerServer)
    let address = InetSocketAddress(this: port())
    connection: connect(address)
    println("listening on " + this: port() + " port.")
    return this
  }
}