//
//  CustomTextFailed.swift
//  ExpDate
//
//  Created by mai abdullah qurun on 13/05/1444 AH.
//

import SwiftUI

struct CustomTextField: View {
    
    let label: String
    let placeholder: String
    @Binding var text: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack(alignment: .leading) {
        Text(label)
                
        .font(.subheadline)
        .foregroundColor(.primary) .bold()
        .padding(.horizontal, 10)
        .background(colorScheme == .light ? .white : Color(uiColor: .systemGray6))
        .cornerRadius(5)
        .offset(y: -23)
            if label == "Product Name" {
                TextField(placeholder, text: $text)
            } else {
                Rectangle()
                    .fill(Color.clear)
                    .overlay(alignment: .leading) {
                        Text(text == "" ? placeholder : text)
                            .foregroundColor(text == "" ? colorScheme == .light ? Color(uiColor: .systemGray3) : Color(uiColor: .systemGray) : .primary)
                    }
            }
        }
        .font(.callout)
        .foregroundColor(.primary)
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .frame(height: 40)
        .background(
        RoundedRectangle(cornerRadius: 8)
        .stroke(.gray.opacity(0.9), lineWidth: 0.5)
        .background(colorScheme == .light ? .white : Color(uiColor: .systemGray6))
        .cornerRadius(8)
        )
    }
}

struct CustomTextFailed_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CustomTextField(label: "Product Name", placeholder: "enter", text: .constant(""))
            CustomTextField(label: "exp date", placeholder: "enter", text: .constant(""))
        }
        .padding()
    }
}
