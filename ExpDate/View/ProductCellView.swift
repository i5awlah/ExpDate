//
//  ProductCellView.swift
//  ExpDate
//
//  Created by Lamia Aldossari on 08/12/2022.
//

import SwiftUI

struct ProductCellView: View {
    @State var valueProgress: Double = 20
    
    let productName: String
    let productImage: String
    let leftDate: String
    
    var body: some View {
        
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.white)
            .frame(height: 88)
            .shadow(radius: 1.5, x: 0, y: 0.5)
            .overlay(alignment:.leading){
                VStack {
                    HStack(alignment: .top) {
                        
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(uiColor: .systemGray4) , lineWidth: 0.5)
                            .frame(width: 60, height: 60)
                            .overlay{
                                AsyncImage(url: URL(string: "https://i-cf65.ch-static.com/content/dam/cf-consumer-healthcare/panadol/en_eg/Products/455x455-en%20eg_new.jpg?auto=format")) { image in
                                    image
                                        .resizable()
                                        .frame(width: 50,height:50)
                                        .clipShape(Rectangle())
                                } placeholder: {
                                    ProgressView()
                                }
                            }
                        
                        Text(productName)
                            .font(.system(size: 16))
                            .frame(maxHeight: .infinity)
                        Spacer()
                        
                        Text(leftDate)
                            .font(.caption)
                            .foregroundColor(.gray)
                    
                      
                    }
                    .padding(.top, 10)
                    
                    ProgressView(value: valueProgress, total: 100)
                        .tint(.yellowProgress)
                        .progressViewStyle(.linear)
                        .padding(.bottom, 10)
                }
                .padding(.horizontal, 10)
            }
    }
}
struct ProductCellView_Previews: PreviewProvider {
    static var previews: some View {
        ProductView()
    }
}

