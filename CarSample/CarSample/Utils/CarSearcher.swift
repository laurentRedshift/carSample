enum CarSearcher {
    static let minCharactersAcceptable = 3
    static func search(searchText: String, attribute: String) -> Bool {
        if searchText.count >= minCharactersAcceptable {
            return attribute.contains(searchText.prefix(minCharactersAcceptable))
            
        } else {
            return attribute.contains(searchText)
        }
    }
}
