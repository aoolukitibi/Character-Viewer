//
//  CharacterViewerModelObjects.swift
//  Simpsons Character Viewer
//
//  Created by ANTHONY O. on 1/30/19.
//  Copyright © 2019 ANTHONY O. All rights reserved.
//

import Foundation

var characterListArray: Array<Any> = []
var characterIndex = Int()
var filteredcharacterListArray: Array<Any> = characterListArray

struct CharacterIcon: Decodable {
    let URL: String?
}

struct Character: Decodable {
    let Text: String?
    let Icon: CharacterIcon?
}

struct Characters: Decodable {
    let RelatedTopics: [Character]?
}

//MARK: FetchData
func getDataFromURL() {
    #if TheWire
    let url = URL(string: "https://api.duckduckgo.com/?q=the+wire+characters&format=json")
    #else
    let url = URL(string: "https://api.duckduckgo.com/?q=simpsons+characters&format=json")
    #endif
    
    let task = URLSession.shared.dataTask(with: url!) {
        ( data, response, error) in
        if let httpResponse = response as? HTTPURLResponse {
            do {
                let characters = try JSONDecoder().decode(Characters.self, from: data!)
                if let charaterArray = characters.RelatedTopics{
                    characterListArray = charaterArray
                    filteredcharacterListArray = charaterArray
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dataResponseReceived"), object: nil)
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            print("The status code is \(httpResponse.statusCode)")
        }
    }
    task.resume()
}

