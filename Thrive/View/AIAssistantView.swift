//
//  AIAssistantView.swift
//  Trackizer
//
//  Created by Brandon Parenteau on 2025-02-18.
//

import SwiftUI

struct AIAssistantView: View {
    @State private var userMessage = ""
    @State private var chatMessages: [(String, Bool)] = [] // (Message, isUser)

    var body: some View {
        VStack {
            ScrollView {
                ForEach(chatMessages, id: \.0) { message, isUser in
                    HStack {
                        if isUser { Spacer() }
                        Text(message)
                            .padding()
                            .background(isUser ? Color.blue : Color.gray.opacity(0.2))
                            .cornerRadius(12)
                            .foregroundColor(isUser ? .white : .black)
                        if !isUser { Spacer() }
                    }
                    .padding(.horizontal, 10)
                }
            }

            HStack {
                TextField("Ask me about your finances...", text: $userMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: 44)

                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding()
        }
    }

    func sendMessage() {
        guard !userMessage.isEmpty else { return }
        
        chatMessages.append((userMessage, true)) // Add user message to chat
        
        //let transactions = fetchTransactions() // Your function to get transactions from Firebase/Plaid
        //let requestBody: [String: Any] = ["userMessage": userMessage, "userTransactions": transactions]
        
        // Send user query to Node.js backend
        //guard let url = URL(string: "http://localhost:5001/ai-assistant") else { return }
       // var request = URLRequest(url: url)
      //  request.httpMethod = "POST"
      //  request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: [])

       // URLSession.shared.dataTask(with: request) { data, _, error in
           // if let data = data, let response = try? JSONDecoder().decode([String: String].self, from: data) {
               // DispatchQueue.main.async {
                  //  chatMessages.append((response["aiResponse"] ?? "No response", false))
                }
            }
      //  }.resume()

      //  userMessage = "" // Clear input
 //   }
//}

#Preview {
    AIAssistantView()
}
