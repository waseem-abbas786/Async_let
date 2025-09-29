
import Foundation

struct Post: Codable, Identifiable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

struct User: Codable, Identifiable {
    let id: Int
    let name: String
    let username: String
    let email: String
}

class  ConcurrencyViewModel : ObservableObject {
       @Published var postText: String = ""
       @Published var userText: String = ""
       @Published var errorMessage: String? = nil
       @Published var isLoading: Bool = false
    private let postKey = "savedPracticePost"
        private let userKey = "savedPracticeUser"
    
    func fetchUserAndPost (postId : Int , userId : Int) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false}
        do {
           async let post = fetchPost(id: postId)
            async let user = fetchUser(id: userId)
            let (postResult , userResult) = try await (post , user)
            postText = """
                Post #\(postResult.id) by user \(postResult.userId)
                Title: \(postResult.title)
                 \(postResult.body)
                """
            userText = """
                User #\(userResult.id): \(userResult.name) (@\(userResult.username))
                Email: \(userResult.email)
                """
            let postData = try JSONEncoder().encode(postResult)
            let userData = try JSONEncoder().encode(userResult)
            UserDefaults.standard.set(postData, forKey: postKey)
            UserDefaults.standard.set(userData, forKey: userKey)
        } catch  {
            errorMessage = "Fetch error: \(error.localizedDescription)"
            postText = ""
            userText = ""
        }
    }
    
    func loadSavedData () {
        if let postData = UserDefaults.standard.data(forKey: postKey),
           let savedPost = try? JSONDecoder().decode(Post.self, from: postData) {
            postText = """
                       Post #\(savedPost.id) by user \(savedPost.userId)
                       Title: \(savedPost.title)

                       \(savedPost.body)
                       """
        } else {
            postText = ""
        }
        if let userData = UserDefaults.standard.data(forKey: userKey),
           let savedUser = try? JSONDecoder().decode(User.self, from: userData) {
            userText = """
                      User #\(savedUser.id): \(savedUser.name) (@\(savedUser.username))
                      Email: \(savedUser.email)
                      """
        }
        else {
            userText = ""
        }
        errorMessage = nil
    }

    private func fetchPost (id : Int) async throws -> Post {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts/\(id)") else {  throw URLError(.badURL)}
        let ( data , _ ) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(Post.self, from: data)
    }
    private func fetchUser (id : Int) async throws -> User {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/users/\(id)") else { throw URLError(.badURL)}
        let (data ,_) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(User.self, from: data)
    }
}
