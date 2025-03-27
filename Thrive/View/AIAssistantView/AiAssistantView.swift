//
//  AiAssistantView.swift
//  Trackizer
//
//  Created by Brandon Parenteau on 2025-02-23.
//

import SwiftUI

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

struct AIAssistantChatView: View {
    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "Hello! How can I assist you today?", isUser: false)
    ]
    @State private var inputText: String = ""
    @State private var isLoading: Bool = false

    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(messages) { message in
                            ChatBubble(message: message)
                        }
                        if isLoading {
                            ProgressView()
                                .padding()
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _ in
                    withAnimation {
                        proxy.scrollTo(messages.last?.id, anchor: .bottom)
                    }
                }
            }

            HStack {
                TextField("Type a message...", text: $inputText)
                    .padding()
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(10)
                    .foregroundColor(.white) // Text color when typing
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 1)) // Border color
                    .placeholder(when: inputText.isEmpty) { // Custom placeholder
                        Text("Type a message...")
                            .foregroundColor(.gray)
                    }

                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .clipShape(Circle())
                }
                .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()
        }
        .navigationTitle("AI Assistant")
        .background(Color.grayC)
    }

    func sendMessage() {
        let userMessage = ChatMessage(text: inputText, isUser: true)
        messages.append(userMessage)
        inputText = ""
        isLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {  // Simulating AI response
            let aiResponse = ChatMessage(text: "This is a placeholder AI response.", isUser: false)
            messages.append(aiResponse)
            isLoading = false
        }
    }
}

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            Text(message.text)
                .padding()
                .background(message.isUser ? Color.blue : Color.blue.opacity(0.2))
                .foregroundColor(message.isUser ? .white : .white)
                .cornerRadius(15)
                .frame(maxWidth: 250, alignment: message.isUser ? .trailing : .leading)
            if !message.isUser { Spacer() }
        }
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        overlay(
            ZStack(alignment: alignment) {
                if shouldShow { placeholder() }
                self
            }
        )
    }
}

struct AIAssistantChatView_Previews: PreviewProvider {
    static var previews: some View {
        AIAssistantChatView()
    }
}
