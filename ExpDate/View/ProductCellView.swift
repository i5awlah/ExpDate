//
//  ProductCellView.swift
//  ExpDate
//
//  Created by Lamia Aldossari on 08/12/2022.
//

import SwiftUI

struct ProductCellView: View {
    var valueProgress: Double {
        let dayLeft = Double (product.associatedRecord.creationDate?.diff_day ?? 0) * -1
        let total = Double (product.expiry.diff_day) + dayLeft
        return (dayLeft * 100) / total
    }

    let product: ProductModel
    
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
                                AsyncImage(url: URL(string: product.imageurl)) { image in
                                    image
                                        .resizable()
                                        .frame(width: 50,height:50)
                                        .clipShape(Rectangle())
                                } placeholder: {
                                    ProgressView()
                                }
                            }
                        
                        Text(product.name)
                            .font(.system(size: 16))
                            .frame(maxHeight: .infinity)
                        Spacer()
                        
                        Text(product.expiry.polite)
                            .font(.caption)
                            .foregroundColor(product.expiry.polite == "Expired" ? .red : .gray)
                    
                      
                    }
                    .padding(.top, 10)
                    
                    ProgressView(value: valueProgress, total: 100)
                        .tint( valueProgress > 85 ? .redProgress : .yellowProgress)
                        .progressViewStyle(.linear)
                        .padding(.bottom, 10)
                }
                .padding(.horizontal, 10)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .frame(height: 88)
                    .opacity(product.expiry.polite == "Expired" ? 0.6 : 0)
            }
    }
}
struct ProductCellView_Previews: PreviewProvider {
    static var previews: some View {
        ProductCellView(product: ProductModel.testProduct)
    }
}
