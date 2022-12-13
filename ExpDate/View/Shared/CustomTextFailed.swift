//
//  CustomTextFailed.swift
//  ExpDate
//
//  Created by mai abdullah qurun on 13/05/1444 AH.
//

import SwiftUI

struct CustomText: View {
    
    let label: String
    @Binding var text: String
    
    var body: some View {
        ZStack(alignment: .leading) {
        Text(label)
                
        .font(.subheadline)
        .foregroundColor(.black) .bold()
        .padding(.horizontal, 10)
        .background(.white)
        .cornerRadius(5)
        .offset(y: -23)
        TextField("", text: $text)
        }
        .foregroundColor(.black)
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .frame(height: 40)
        .background(
        RoundedRectangle(cornerRadius: 8)
        .stroke(.gray.opacity(0.9), lineWidth: 0.5)
        .background(.white)
        .cornerRadius(8)
        )
    }
}

struct CustomTextFailed_Previews: PreviewProvider {
    static var previews: some View {
        CustomText(label: "name", text: .constant("may"))
    }
}
