//
//  MovieCast.swift
//  Film App
//
//  Created by Вероника Данилова on 17/12/2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.
//

import Foundation

struct MovieCast {
    
    var actors: [String] = []
    var director: String?
    var writer: String?
    var producers: [String] = []
    
    
    init?(ofType type: MediaType,from json: [String: Any]) {
        
        guard let cast = json["cast"] as? [Dictionary<String, Any>],
            let crew = json["crew"] as? [Dictionary<String, Any>] else {
                return nil
        }
        
        var castQuantity: Int!
        if cast.count >= 10 {
            castQuantity = 10
        } else {
            castQuantity = cast.count
        }
        
        for i in 0..<castQuantity {
            let actor = cast[i]
            if let name = actor["name"] as? String {
                self.actors.append(name)
            }
        }
        
        for member in crew {
            
            if let job = member["job"] as? String,
                let name = member["name"] as? String {
                
                if type == MediaType.movie {
                    
                    switch job {
                    case "Director":
                        self.director = name
                    case "Writer":
                        self.writer = name
                    case "Producer":
                        self.producers.append(name)
                    default:
                        ()
                    }
                    
                } else {
                    
                    switch job {
                    case "Director":
                        self.director = name
                    case "Novel":
                        self.writer = name
                    case "Executive Producer":
                        self.producers.append(name)
                    default:
                        ()
                    }
                    
                }
                
                
            }
            
        }
        
    }
    
}
