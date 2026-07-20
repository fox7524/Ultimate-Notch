import Foundation
import Network

let path = "/tmp/test.sock"
unlink(path)
let params = NWParameters(tls: nil, tcp: NWProtocolTCP.Options())
params.requiredLocalEndpoint = NWEndpoint.unix(path: path)
params.allowLocalEndpointReuse = true
do {
    let listener = try NWListener(using: params)
    listener.stateUpdateHandler = { state in print(state) }
    listener.start(queue: .main)
    RunLoop.main.run(until: Date(timeIntervalSinceNow: 1))
} catch {
    print(error)
}
