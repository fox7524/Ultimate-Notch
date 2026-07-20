import Foundation
import Network

let path = "/tmp/test.sock"
let connection = NWConnection(to: .unix(path: path), using: .tcp)
connection.stateUpdateHandler = { state in print(state) }
connection.start(queue: .main)
RunLoop.main.run(until: Date(timeIntervalSinceNow: 1))
