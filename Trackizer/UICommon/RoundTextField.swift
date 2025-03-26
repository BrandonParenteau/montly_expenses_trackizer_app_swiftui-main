//
//  RoundTextField.swift
//  Trackizer
//
//  Created by CodeForAny on 11/07/23.
//

import SwiftUI
import UIKit

struct RoundTextField: View {
    @State var title: String = "Title"
    @Binding var text: String
    @State var keyboardType: UIKeyboardType = .default
    var textAlign: Alignment = .leading
    var isPassword: Bool = false
    
    var body: some View {
        VStack {
            Text(title)
                .multilineTextAlignment(.leading)
                .font(.customfont(.regular, fontSize: 14))
                .frame(minWidth: 0, maxWidth: .infinity, alignment: textAlign)
                .foregroundColor(.gray50)
                .padding(.bottom, 4)
            
            if isPassword {
                CustomTextField(text: $text, isSecure: true, keyboardType: keyboardType)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.gray70, lineWidth: 1)
                            .background(Color.gray60.opacity(0.05))
                            .cornerRadius(15)
                    )
            } else {
                CustomTextField(text: $text, isSecure: false, keyboardType: keyboardType)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.gray70, lineWidth: 1)
                            .background(Color.gray60.opacity(0.05))
                            .cornerRadius(15)
                    )
            }
        }
    }
}

struct CustomTextField: UIViewRepresentable {
    @Binding var text: String
    var isSecure: Bool
    var keyboardType: UIKeyboardType
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.isSecureTextEntry = isSecure
        textField.keyboardType = keyboardType
        textField.backgroundColor = .clear
        textField.textColor = .white
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.inputAssistantItem.leadingBarButtonGroups = []
        textField.inputAssistantItem.trailingBarButtonGroups = []
        
        // Add padding
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        
        init(text: Binding<String>) {
            self._text = text
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }
    }
}

struct RoundTextField_Previews: PreviewProvider {
    @State static var txt: String = ""
    static var previews: some View {
        RoundTextField(text: $txt)
    }
}
