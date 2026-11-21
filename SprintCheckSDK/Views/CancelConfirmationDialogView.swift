import SwiftUI

public struct CancelConfirmationDialogView: View {

    let onIgnore: () -> Void
    let onCancel: () -> Void

    public init(onIgnore: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self.onIgnore = onIgnore
        self.onCancel = onCancel
    }

    public var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    onIgnore()
                }

            VStack(spacing: 20) {
                Text("Are you sure you want to cancel")
                    .font(.headline)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)

                Text("Cancelling will end verification and erase your details. Ignore this message if it was a mistake.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)

                VStack(spacing: 12) {
                    Button(action: onIgnore) {
                        Text("Ignore")
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.black)
                            .cornerRadius(8)
                    }

                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.red)
                            .padding(.vertical, 4)
                    }
                }
                .padding(.top, 8)
            }
            .padding(24)
            .frame(width: 320)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
        }
    }
}
