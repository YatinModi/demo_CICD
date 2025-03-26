//
//  DataModel.swift
//  MommyMap
//
//  Created by getyoteam solution llp on 26/09/24.
//

import Foundation

class DataModel: NSObject {
    
    var FirebaseDataArr = [firebaseDataModel]()
    
    init(fromDictionary dict : NSArray) {
        for data in dict
        {
            if data is NSDictionary {
                FirebaseDataArr.append(firebaseDataModel.init(fromDictionary: data as! NSDictionary))
            }
        }
    }
}

class firebaseDataModel: NSObject
{
    var id : Int!
    var address : String!
    var addressShortForm : String!
    var breastFeedingFriendly : String!
    var country : String!
    var diaperChangingArea : String!
    var kidsMenu : String!
    var latLong : String!
    var titleName : String!
    var playArea : String!
    var programCalendar : String!
    var type : String!
    var website : String!
    var notesReCalendar : String!
    var cityName : String!
    var Neighbourhood : String!
    
    var isGrayMarker : Bool!
    var isSelectedCategory : String!

    init(fromDictionary dictionary: NSDictionary)
    {
        self.id = dictionary.getIntValue(key: "ID")
        self.address = dictionary.getStringValue(key: "Address")
        self.addressShortForm = dictionary.getStringValue(key: "AddressShortForm")
        self.breastFeedingFriendly = dictionary.getStringValue(key: "BreastFeedingCozy")
        self.country = dictionary.getStringValue(key: "Country")
        self.diaperChangingArea = dictionary.getStringValue(key: "DiaperChangingArea")
        self.kidsMenu = dictionary.getStringValue(key: "KidsMenu")
        self.latLong = dictionary.getStringValue(key: "LatLong")
        self.titleName = dictionary.getStringValue(key: "Name")
        self.playArea = dictionary.getStringValue(key: "PlayArea")
        self.programCalendar = dictionary.getStringValue(key: "ProgramCalendar")
        self.type = dictionary.getStringValue(key: "Type")
        self.website = dictionary.getStringValue(key: "Website")
        self.notesReCalendar = dictionary.getStringValue(key: "NotesReCalendar")
        self.cityName = dictionary.getStringValue(key: "City")
        self.Neighbourhood = dictionary.getStringValue(key: "Neighbourhood")
        
        self.isGrayMarker = false
        self.isSelectedCategory = ""
        
    }
}
