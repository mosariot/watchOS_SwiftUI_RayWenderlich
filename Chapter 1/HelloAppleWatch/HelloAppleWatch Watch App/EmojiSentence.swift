import SwiftUI

@MainActor
final class EmojiSentence: ObservableObject {
    @Published var text = ""
    @Published var emoji = ""

    private let sentences = [
        (text: "Not my cup of tea", emoji: "πββοΈ βοΈ"),
        (text: "Talk to the hand", emoji: "π β"),
        (text: "Not the brightest bulb", emoji: "π« π π‘"),
        (text: "When pigs fly", emoji: "β° π· βοΈ"),
        (text: "Boy who cried wolf", emoji: "πΆπ­πΊ")
    ]
    private var index = 0

    init() {
        update()
    }

    func next() {
        index += 1
        if index == sentences.count {
            index = 0
        }

        update()
    }

    private func update() {
        text = sentences[index].text
        emoji = sentences[index].emoji
    }
}
