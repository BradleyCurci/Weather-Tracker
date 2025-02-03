//
//  APIClient.swift
//  Weather Tracker
//
//  Created by Brad Curci on 1/29/25.
//  APIClient is a robust HTTPS request handler utilizing concurrency and multithreading to perform background tasks without effecting UX

import Foundation

class APIClient {
    
//  Singleton initialization
    static let shared = APIClient()
    
    private init() {}
    
//  Error classifications
    public enum APIError: Error {
        
//      local errors
        case invalidURL
        case nilData
        case decodingError
        
//      non-200 response errors
        case informational  //(100 - 199)
        case redirection    //(300 - 399)
        case clientError    //(400 - 499)
        case serverError    //(500 - 599)
    }
    
    
//  MARK: Main request
    func request<T: Decodable>(
        baseURL        : String,
        method         : String = "GET",
        parameters     : [String : Any]? = nil,
        headers        : [String : String]? = nil,
        body           : Data? = nil,
        printResponse  : Bool = false, // Debugging
        completion     : @escaping (Result<T, Error>) -> Void
    ){
        
//      Build URL Component
        guard var urlComponent = URLComponents(string: baseURL) else {
            completion(.failure(APIError.invalidURL)) // Terminate if invalid url
            return
        }
        
        
//      Append query parameters for method of type GET
        /** HTTPS handles parameters differently for GET requests
            as apposed to other methods. To account for this, we must
            map each key value pair to our URL.*/
        if method.uppercased() == "GET", let parameters = parameters {
            urlComponent.queryItems = parameters.map { key, value in
                URLQueryItem(name: key, value: String(describing: value))
            }
        }
        
        guard let url = urlComponent.url else {
            completion(.failure(APIError.invalidURL)) // Terminate if error
            return
        }
        
        
//      Init request + defaults
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
//       Append headers
        if let headers = headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        
//      Manager parameters for non-GET methods
        if method.uppercased() != "GET" {
            if let body = body {
                request.httpBody = body
            } else if let parameters = parameters {
                request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
            }
        }
        
        
//      Request
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.nilData))
                return
            }
            
            
//          Retrieve status code and respond accordingly
            var statusCode = 0
            if let httpResponse = response as? HTTPURLResponse {
                statusCode = httpResponse.statusCode
                switch httpResponse.statusCode {
                    case 100...199:
                        self.printResponse(data)
                        completion(.failure(APIError.informational))
                        return
                    case 200...299:
                        break
                    case 300...399:
                        self.printResponse(data)
                        completion(.failure(APIError.redirection))
                        return
                    case 400...499:
                        self.printResponse(data)
                        completion(.failure(APIError.clientError))
                        return
                    default:
                        self.printResponse(data)
                        completion(.failure(APIError.serverError))
                        return
                }
            }
            
            do {
//              Success
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                print(String(describing: error))
                completion(.failure(error))
            }
            
            if printResponse{
                print("Status Code: \(statusCode)")
                self.printResponse(data)
            }
        }
        task.resume()
    }
    

//  MARK: Async Request
    func asyncRequest<T: Decodable>(
        baseURL        : String,
        method         : String = "GET",
        parameters     : [String : Any]? = nil,
        headers        : [String : String]? = nil,
        body           : Data? = nil,
        printResponse  : Bool = false // Debugging
    ) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            request(
                baseURL: baseURL,
                method: method,
                parameters: parameters,
                headers: headers,
                body: body,
                printResponse: printResponse
            ) { (result: Result<T, Error>) in
                switch result {
                    case .success(let data):
                        continuation.resume(returning: data)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                }
            }
        }
    }
    

//  Pretty print JSON Response
    private func printResponse(_ JSONData: Data) {
        if let JSONObject = try? JSONSerialization.jsonObject(with: JSONData, options: []),
        let prettyData = try? JSONSerialization.data(withJSONObject: JSONObject, options: .prettyPrinted),
        let prettyString = String(data: prettyData, encoding: .utf8) {
            print(prettyString)
        }
    }
}
