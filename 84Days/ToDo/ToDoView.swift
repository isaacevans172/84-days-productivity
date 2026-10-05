//
//  ToDoView.swift
//  84Days
//
//  Created by yuvan harith on 5/10/2026.
//

import SwiftUI

struct TaskItem : Identifiable{
    let id = UUID ()
    
    var title: String = ""
    var category: String = ""
    var duration: String = ""
    var priority: Priority = .medium
    var completed: Bool = false
}
enum Priority: String {
    case high = "High"
    case medium = "Medium"
    case low = "Low"
}

struct TaskPriorityGroupsView: View {
    
    @State private var tasks: [TaskItem] = []
    
    var body:some View {
        List {
            DisclosureGroup {
                
                ForEach($tasks.filter { $0.wrappedValue.priority == .high }) { $task in
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color("bubblecolor"))
                            .frame(width: 350, height: 70)
                        
                        TextField("Enter task...", text: $task.title)
                        
                        Button {
                               task.completed.toggle()
                           } label: {
                               Image(systemName: task.completed ? "checkmark.circle.fill" : "circle")
                                   .font(.system(size: 22))
                           }
                       }
                       .padding(.horizontal, 20)

                    }
                }
                
            } label: {
                HStack {
                    Text("High")
                        .font(.system(size: 20))
                        .fontWeight(.semibold)
                        .padding(.horizontal, 31)
                        .padding(.vertical, 10)
                        .background(Color("high"))
                        .clipShape(Capsule())
                    
                    Spacer()
                    
                    Button {
                        tasks.append(
                            TaskItem(priority: .high)
                        )
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 20))
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        
    
                List {
                    DisclosureGroup {
                        
                        ForEach($tasks.filter { $0.wrappedValue.priority == .medium }) { $task in
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color("bubblecolor"))
                                    .frame(width: 350, height: 70)
                                
                                TextField("Enter task...", text: $task.title)
                                    .padding(.horizontal, 20)
                            }
                        }
                        
                    } label: {
                        HStack {
                            Text("medium")
                                .font(.system(size: 20))
                                .fontWeight(.semibold)
                                .padding(.horizontal, 31)
                                .padding(.vertical, 10)
                                .background(Color("medium"))
                                .clipShape(Capsule())
                            
                            Spacer()
                            
                            Button {
                                tasks.append(
                                    TaskItem(priority: .medium)
                                )
                            } label: {
                                Image(systemName: "plus")
                                    .font(.system(size: 20))
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                
                
                
                
                
        List {
            DisclosureGroup {
                
                ForEach($tasks.filter { $0.wrappedValue.priority == .low }) { $task in
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color("bubblecolor"))
                            .frame(width: 350, height: 70)
                        
                        TextField("Enter task...", text: $task.title)
                            .padding(.horizontal, 20)
                    }
                }
                
            } label: {
                HStack {
                    Text("low")
                        .font(.system(size: 20))
                        .fontWeight(.semibold)
                        .padding(.horizontal, 31)
                        .padding(.vertical, 10)
                        .background(Color("low"))
                        .clipShape(Capsule())
                    
                    Spacer()
                    
                    Button {
                        tasks.append(
                            TaskItem(priority: .low)
                        )
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 20))
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
                
        


#Preview {
    TaskPriorityGroupsView()
}
}
