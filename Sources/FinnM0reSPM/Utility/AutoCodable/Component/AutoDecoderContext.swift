import Foundation

struct AutoDecoderContext {
    let givenPath: AutoDecodePath?
    var inferredPath: AutoDecodePath?

    var preferredPath: AutoDecodePath {
        if let givenPath {
            return givenPath
        }
        else if let inferredPath {
            return inferredPath
        }
        else {
            return AutoDecodePath()
        }
    }
}
