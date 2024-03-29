//
//  DynamicFilterView.swift
//  Tasky (iOS)
//
//  Created by KET on 04/05/2022.
//

import SwiftUI
import CoreData

struct DynamicFilterView<T, Content: View>: View where T: NSManagedObject {
    // MARK: Core Data Request
    @FetchRequest var request: FetchedResults<T>
    let content: (T) -> Content
    
    // MARK: Building custom ForEach to give the result
    init(currentTab: String, @ViewBuilder content: @escaping (T) -> Content) {
//        MARK: Predicate to Filter current date Task
        let calendar = Calendar.current
        var predicate: NSPredicate!
        
        if currentTab == "Today" {
            let today = calendar.startOfDay(for: Date())
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)
            
            let filterKey = "deadline"
            
            predicate = NSPredicate(format: "\(filterKey) >= %@ AND \(filterKey) < %@ AND isCompleted == %i", argumentArray: [today, tomorrow, 0])
        } else if currentTab == "Upcoming" {
            let today = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: Date())!)
            let tomorrow = Date.distantFuture
            
            let filterKey = "deadline"
            
            predicate = NSPredicate(format: "\(filterKey) >= %@ AND \(filterKey) < %@ AND isCompleted == %i", argumentArray: [today, tomorrow, 0])
        } else if currentTab == "Failed" {
            let today = calendar.startOfDay(for: Date())
            let past = Date.distantPast
            
            let filterKey = "deadline"
            
            predicate = NSPredicate(format: "\(filterKey) > %@ AND \(filterKey) < %@ AND isCompleted == %i", argumentArray: [past, today, 0])
        } else {
            predicate = NSPredicate(format: "isCompleted == %i", argumentArray: [1])
        }
        
        
        // MARK: Intializing request with NSPredicate
        _request = FetchRequest(entity: T.entity(), sortDescriptors: [.init(keyPath: \Task.deadline, ascending: false)], predicate: predicate)
        self.content = content
    }
    
    var body: some View {
        if request.isEmpty {
            Text("Not found any task!")
                .font(.system(size: 16))
                .fontWeight(.light)
                .offset(y: 100)
        } else {
            ForEach(request, id: \.objectID) { object in
                self.content(object)
            }
        }
    }
}
