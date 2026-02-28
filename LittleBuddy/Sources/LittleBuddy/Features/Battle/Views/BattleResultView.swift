import SwiftUI

struct BattleResultView: View {
    let won: Bool
    let onDismiss: () -> Void
    @State private var animateScale = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text(won ? "🎉" : "😢")
                    .font(.system(size: 80))
                    .scaleEffect(animateScale ? 1.0 : 0.3)
                    .animation(.spring(response: 0.5, dampingFraction: 0.5), value: animateScale)

                Text(won ? "你赢了！" : "你输了…")
                    .font(.largeTitle.bold())
                    .foregroundStyle(won ? .green : .orange)

                Text(won ? "太厉害了！你的小伙伴赢了！🏆" : "没关系，下次一定赢！加油！💪")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)

                Button("返回首页 🏠") {
                    onDismiss()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(won ? .green : .blue)
            }
            .padding(32)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(radius: 20)
            .padding(24)
        }
        .onAppear { animateScale = true }
    }
}
