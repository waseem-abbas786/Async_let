//
//  ContentView.swift
//  Async_let
//
//  Created by Waseem Abbas on 29/09/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var vm = ConcurrencyViewModel()

       @State private var postIdText: String = "1"
       @State private var userIdText: String = "1"

       var body: some View {
           NavigationView {
               ScrollView {
                   VStack(spacing: 16) {
                       Group {
                           HStack {
                               TextField("Post ID", text: $postIdText)
                                   .keyboardType(.numberPad)
                                   .textFieldStyle(RoundedBorderTextFieldStyle())
                               TextField("User ID", text: $userIdText)
                                   .keyboardType(.numberPad)
                                   .textFieldStyle(RoundedBorderTextFieldStyle())
                           }
                       }
                       .padding(.horizontal)

                       HStack(spacing: 12) {
                           Button(action: {
                               guard let postId = Int(postIdText), let userId = Int(userIdText) else {
                                   vm.errorMessage = "Enter valid numeric IDs"
                                   return
                               }
                               Task {
                                   await vm.fetchUserAndPost(postId: postId, userId: userId)
                               }
                           }) {
                               HStack {
                                   if vm.isLoading { ProgressView().scaleEffect(0.8) }
                                   Text("Fetch (parallel)")
                               }
                               .padding()
                               .frame(maxWidth: .infinity)
                           }
                           .buttonStyle(.borderedProminent)

                           Button("Load Saved") {
                               vm.loadSavedData()
                           }
                           .buttonStyle(.bordered)
                       }
                       .padding(.horizontal)

                       if let err = vm.errorMessage {
                           Text(err)
                               .foregroundColor(.red)
                               .padding(.horizontal)
                       }

                       Group {
                           Text("🔹 Post Result")
                               .font(.headline)
                               .frame(maxWidth: .infinity, alignment: .leading)
                               .padding(.horizontal)

                           TextEditor(text: .constant(vm.postText))
                               .frame(height: 180)
                               .padding(6)
                               .background(Color(.systemGray6))
                               .cornerRadius(8)
                               .disabled(true)
                               .padding(.horizontal)

                           Text("🔹 User Result")
                               .font(.headline)
                               .frame(maxWidth: .infinity, alignment: .leading)
                               .padding(.horizontal)

                           TextEditor(text: .constant(vm.userText))
                               .frame(height: 140)
                               .padding(6)
                               .background(Color(.systemGray6))
                               .cornerRadius(8)
                               .disabled(true)
                               .padding(.horizontal)
                       }

                       Spacer()
                   }
                   .padding(.vertical)
               }
               .navigationTitle("async let+UserDefaults")
               .onAppear {
                   // Optionally load saved data on appear
                   vm.loadSavedData()
               }
           }
       }
}

#Preview {
    ContentView()
}
