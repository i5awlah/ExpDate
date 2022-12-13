//
//  MembersView.swift
//  ExpDate
//
//  Created by Khawlah on 06/12/2022.
//

import SwiftUI

struct MembersView: View {
    
    var body: some View {
        
        VStack(alignment: .leading){
            
            List{
                MemberCell(email: "email@domain.com")
                MemberCell(email: "ccc@domain.com")
                MemberCell(email: "rrr@domain.com")
            } .listStyle(.plain)
            VStack {
                ZStack{
                    Divider()
                    Text("Add new member by:")
                        .padding(.horizontal)
                        .background(.white)
                        .padding(.leading)
                }
                
                VStack{
                    Button {
                        add()
                    } label: {
                        Text( "Share invite Link")
                            .bold()
                            .padding()
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                            .padding(.top)
                        
                        
                    }
                }
            }
            .padding(.horizontal, 30)
            
            
            
        }
        
        .navigationTitle("Members")
        .navigationBarTitleDisplayMode(.large)
    }
    
    func add(){
        
    }
}

struct MembersView_Previews: PreviewProvider {
    static var previews: some View {
//                                NavigationView {
//                                    NavigationLink {
//                                        MembersView()
//                                    } label: {
//                                        Text("Goo")
//                                    }
//                                    .navigationTitle("My List")
//                                }
//        
//        
        NavigationView {MembersView()}
    }
}
