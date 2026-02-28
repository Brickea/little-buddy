import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Text("小伙伴 🥳")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("用语言创造你的专属小怪兽！")
                    .font(.title3)
                    .foregroundStyle(.secondary)

                NavigationLink("创建新伙伴") {
                    CharacterCreationView()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding()
            .navigationTitle("Little Buddy")
        }
    }
}

#Preview {
    ContentView()
}
