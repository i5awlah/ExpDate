//
//  MemberCell.swift
//  ExpDate
//
//  Created by roua alsahli on 13/05/1444 AH.
//

import SwiftUI

struct MemberCell: View {
    let email: String
    var body: some View {
        HStack{
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 60, height: 60)
            
            Text(email)
                .font(.system(size: 18))
                .padding()
                .accentColor(.blue)
            Spacer()
            
        }.padding()
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .padding(.vertical)
            .background(.gray.opacity(0.1))
            .cornerRadius(10)
            .listRowSeparator(.hidden)
        
        
    }
}

struct MemberCell_Previews: PreviewProvider {
    static var previews: some View {
        MemberCell(email: "email@domain.com")
    }
}
