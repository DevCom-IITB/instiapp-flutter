//
//  MessMenu.swift
//  MessMenu
//
//  Created by Harsh Jha on 02/04/22.
//  Copyright © 2022 The Chromium Authors. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents

// define a structure
struct MealMenu : Codable{
    
    // define two properties
    var id: String
    var day: Int
    var breakfast: String
    var lunch: String
    var snacks: String
    var dinner: String
    var hostel: String
}

struct HostelMenu: Codable{
    var id: String
    var name : String
    var short_name: String
    var long_name: String
    var mess: [MealMenu]
}






struct Provider: IntentTimelineProvider {
    
    func hostel(for configuration: Hostel_numberIntent)-> Int {
        switch configuration.hostel{
        case .hostel1:
            return 1
        case .hostel2:
            return 2
        case .hostel3:
            return 3
        case .hostel4:
            return 4
        case .hostel5:
            return 5
        case .hostel6:
            return 6
        case .hostel7:
            return 7
        case .hostel8:
            return 8
        case .hostel9:
            return 9
        case .hostel10:
            return 10
        case .hostel11:
            return 11
        case .hostel12:
            return 12
        case .hostel13:
            return 13
        case .hostel14:
            return 14
        case .hostel15:
            return 15
        case .hostel16:
            return 16
        case .hostel17:
            return 17
        case .hostel18:
            return 18
            
        default:
            return 3;
        }
    }
    
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), day: 1, mealType: "Lunch", menuOfMeal: "1.Masala Dosa/Rawa Dosa\r\n2.Sambhar & coconut \r\nchutney \r\n3. sweetcorn", configuration: Hostel_numberIntent())
    }
    
    func getSnapshot(for configuration: Hostel_numberIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(),day: 2, mealType: "Lunch", menuOfMeal: "1.Masala Dosa/Rawa Dosa\r\n2.Sambhar & coconut \r\nchutney \r\n3. sweetcorn", configuration: Hostel_numberIntent())
        completion(entry)
    }
    
    func getMealOfNow(for hourOfTheDay: Int, for todaysMenu: MealMenu)-> [String] {
        let mealType : String
        let menu : String
        
        if (hourOfTheDay < 10 || hourOfTheDay >= 22) {
            // breakfast
            mealType = "Breakfast";
            menu = todaysMenu.breakfast;
            
        }
        else if (hourOfTheDay < 14) {
            // lunch
            mealType = "Lunch";
            menu = todaysMenu.lunch;
        } else if (hourOfTheDay < 18) {
            // snacks
            mealType = "Snacks";
            menu = todaysMenu.snacks;
            
        } else {
            // dinner
            mealType = "Dinner";
            menu = todaysMenu.dinner;
        }
        return [menu,mealType]
        
        
    }
    
    func getTodayMenu(completion: @escaping ([HostelMenu]) -> Void) {
        //getting menu from api
        
        //        let url = URL(string: "https://api.insti.app/api/mess")
        //        var mealOfNow: String = ""
        
        let url : String = "https://api.insti.app/api/mess"
        //        var request : _quest = NSMutableURLRequest()
        //        request.url = NSURL(string: url) as URL?
        //        request.httpMethod = "GET"
        
        let loanUrl = URL(string: url)
        let task = URLSession.shared.dataTask(with: loanUrl!, completionHandler: { (data, response, error) ->Void in
            
            if let error = error {
                print(error)
                return
            }
            
            // Parse JSON data
            
            do {
                let menu = try JSONDecoder().decode([HostelMenu].self, from: data!)
                completion(menu);
            }
            catch let error{
                print(error.localizedDescription)
            }
            
            
            
            
            // Parse JSON data
            //                            let jsonLoans = jsonResult?["loans"] as! [AnyObject]
            //                            for jsonLoan in jsonLoans {
            //                                var loan = Loan()
            //                                loan.name = jsonLoan["name"] as! String
            //                                loan.amount = jsonLoan["loan_amount"] as! Int
            //                                loan.use = jsonLoan["use"] as! String
            //                                let location = jsonLoan["location"] as! [String:AnyObject]
            //                                loan.country = location["country"] as! String
            //                                loans.append(loan)
            
            
            
        } )
        
        
        task.resume()
        
    }
    
    func getTimeline(for configuration: Hostel_numberIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        let hourOffset = 0
        let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
        
        
        let day = Calendar.current.dateComponents([.weekday], from: Date()).weekday
        
        let hostel = hostel(for: configuration)
        let hourOfTheDay = Calendar.current.component(.hour, from: Date())
        
        getTodayMenu { menu in
            var hostelMenuToday = ""
            var mealType = ""
            for item in menu{
                if( item.short_name == String(hostel)){
                    for daymess in item.mess{
                        if( daymess.day == day){
                            let arr =  getMealOfNow(for: hourOfTheDay, for: daymess)
                            hostelMenuToday = arr[0]
                            mealType = arr[1]
                            break
                        }
                    }
                    break
                }
            }
            let entry = SimpleEntry(date: entryDate, day: hostel, mealType: mealType, menuOfMeal: hostelMenuToday, configuration: configuration)
            
            //            let entry = getMealOfNow(for: hourOfTheDay, for: )
            entries.append(entry)
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
            
            
        }
        
        
    }
}




struct SimpleEntry: TimelineEntry {
    let date: Date
    let day: Int
    let mealType: String
    let menuOfMeal: String
    let configuration: Hostel_numberIntent
}

struct MessMenuEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        Text("Hostel "+String(entry.day))
            .font(.largeTitle)
            .padding(EdgeInsets(top: 10, leading: 0, bottom: 5, trailing: 0))
            .foregroundColor(.blue)
        Text(entry.mealType)
            .font(.headline)
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
            .multilineTextAlignment(.leading)
        Text(entry.menuOfMeal)
            .font(.subheadline)
            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            .multilineTextAlignment(.leading)
        
    }
    
    
    
}

@main
struct MessMenu: Widget {
    let kind: String = "MessMenu"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: Hostel_numberIntent.self , provider: Provider()) { entry in
            MessMenuEntryView(entry: entry)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
                .background(
                    Image("devcom")
                        .resizable()
                        .scaledToFit()
                        .opacity(0.03)
                )
        }
        .configurationDisplayName("Mess Menu")
        .description("Mess menu of the hostel which you selected.")
    }
    
    
    
}

struct MessMenu_Previews: PreviewProvider {
    
    
    
    
    
    
    static var previews: some View {
        MessMenuEntryView(entry: SimpleEntry(date: Date(), day: 2, mealType: "Lunch",menuOfMeal: "hello guys", configuration: Hostel_numberIntent()))
            .padding(.all, 14.0)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}


