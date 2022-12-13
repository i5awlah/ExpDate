//
//  SingleOnbordingView.swift
//  ExpDate
//
//  Created by Khawlah on 08/12/2022.
//

import SwiftUI

struct SingleOnbordingView: View {
    
    @AppStorage("isUserOnboarded") var isUserOnboarded: Bool = false
    let onbordingType: OnbordingType
    
    var body: some View {
        
        VStack(spacing:20) {
            Image(onbordingType.image)
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
            
            Text(onbordingType.title)
                .font(.title).bold()
            
            Text(onbordingType.description)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            if onbordingType == .share {
                Button("Get Started"){
                    withAnimation(.spring()) {
                        isUserOnboarded = true
                    }
                }
                .font(.headline)
                .padding()
                .foregroundColor(.white)
                .frame(width: 300, height: 50)
                .background(Color.accentColor)
                .mask(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }

        }
        .padding(.horizontal,40)
        
        
    }
}

struct SingleOnbordingView_Previews: PreviewProvider {
    static var previews: some View {
        SingleOnbordingView(onbordingType: OnbordingType.scan)
    }
}
