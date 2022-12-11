//
//  ProductView.swift
//  ExpDate
//
//  Created by Khawlah on 06/12/2022.
//

import SwiftUI

enum CategoryType: String, CaseIterable {
    
    case all = "All"
    case food = "Food"
    case medicine = "Medicine"
    case selfCare = "Self care"
}

struct ProductView: View {
    @State var currentTab: CategoryType = .all
    @State private var showListAlert : Bool = false
    @State private var isSheetPresented = false
    @State private var listName = ""
    @State var productName = "Panadol"
    @State var leftDate = "2 day left"
    
    
    
    var body: some View {
        NavigationView {
            VStack {
                
                
                categories
                    .padding(.top, 20)
                    
                
                List {
                    ForEach((1...3).reversed(), id: \.self) { i in
                        
                        ProductCellView(productName: productName, productImage: "" , leftDate: leftDate)
                            .listRowSeparator(.hidden)
                    }
                    .onDelete { i in
                         
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
                
                
//                ScrollView {
//                    VStack(spacing:15) {
//                        ProductCellView(productName: "Indomie instant noodles Curry Flavour", productImage: "" , leftDate: "4 days ago")
//                        ProductCellView(productName: productName, productImage: "" , leftDate: leftDate)
//                        ProductCellView(productName: "cream", productImage: "" , leftDate: "--")
//                    }
//                    .padding(.top, 10)
//                    .padding(.horizontal)
//                }
                
                
                
                Circle()
                    .fill(Color.accentColor)
                    .frame(width:82 , height:82)
                    .overlay(){
                        Image(systemName: "barcode.viewfinder")
                            .foregroundColor(Color.white)
                            .font(.system(size: 30))
                        
                    }.padding(.leading,220)
                
                
                
                
            }
            .actionSheet(isPresented: $isSheetPresented,
                         content: {
                             ActionSheet(title: Text("Choose a list") , message: Text("Choose existing list or create new list") , buttons: [
                                .default(Text("My List"), action: {}),
                                .default(Text("Family List") , action:{}),
                                .default(Text("+ Add new list") , action:{
                                    showListAlert.toggle()
                                    
                                }),
                                .cancel()
                             , ]
                             )
                         })
            // alert without textfeild
//            .alert(isPresented: $showListAlert)
//        {
//
//            Alert(title:Text("List Name"),
//
//
//
//                  message:Text("Please enter the name of list"),
//
//                  primaryButton:.default(Text("Add")), secondaryButton:.destructive(Text("Cancel")))}
            
            .alert("List Name", isPresented: $showListAlert, actions: {
                        TextField("List Name", text: $listName)

                   

                        
                        Button("Add", action: {})
                        Button("Cancel", role: .cancel, action: {})
                    }, message: {
                        Text("Please enter the name of list.")
                    })
            
            .navigationTitle("My List")
            .navigationBarTitleDisplayMode(.inline)
            
            .navigationBarItems(
                
                leading:
                    Button(action: {
                    
                    self.isSheetPresented.toggle()
                }) {
                    Label("Lists", systemImage:"line.3.horizontal" )
                        .foregroundColor(.black)
                }
                    
                    
                ,
                
                
                trailing:
                    NavigationLink(destination: MembersView(), label: {
                    Image(systemName: "person.2.fill")
                        .foregroundColor(.black)
                }
                                           
                                          )
            )

            
            
        }
        
        
    }
    
    var categories: some View {
        HStack(spacing: 0) {
            Spacer()
            ForEach(CategoryType.allCases, id: \.rawValue) { category in
                Button(action: {
                    
                    withAnimation{
                        currentTab = category
                    }
                }, label: {
                    
                    VStack(spacing:12){
                        Text(category.rawValue)
                            .foregroundColor(currentTab == category ? .accentColor : .black)
                        
                        Capsule()
                            .fill( currentTab == category ? Color.accentColor : Color.clear)
                            .frame(height:1.2)
                    }
                    .fixedSize(horizontal: true, vertical: false)
                })
                Spacer()
            }

        }
                    .overlay(alignment: .bottom){
                        Capsule()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height:1.2)
                    }
    }
    
}

struct ProductView_Previews: PreviewProvider {
    static var previews: some View {
        ProductView()
    }
}
