import SwiftUI

struct PrimaryAddButton: View {
    var title: String? = nil
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            if let title = title {
                Label(title, systemImage: "plus")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
//                    .tint(.blue)
//                    .padding(.horizontal, 16)
//                    .padding(.vertical, 8)
//                    .background(Color.blue)
                    .clipShape(Capsule())
                    .shadow(color: Color.blue.opacity(0.3), radius: 4, x: 0, y: 2)
            } else {
                Image(systemName: "plus")
                    .font(.body.weight(.bold))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
//                    .tint(.blue)
//                    .background(Color.blue)
//                    .clipShape(Circle())
                    .shadow(color: Color.blue.opacity(0.3), radius: 4, x: 0, y: 2)
            }
        }
        .buttonStyle(.borderedProminent)
    }
}
