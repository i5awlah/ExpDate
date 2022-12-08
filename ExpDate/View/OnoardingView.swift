//
//  OnoardingView.swift
//  ExpDate
//
//  Created by Khawlah on 06/12/2022.
//

import SwiftUI


enum OnbordingType: CaseIterable {
    case scan
    case track
    case remind
    case share
    
    var image: String {
        switch self {
        case .scan:
            return "scan"
        case .track:
            return "track"
        case .remind:
            return "reminder"
        case .share:
            return "share"
        }
    }
    
    var title: String {
        switch self {
        case .scan:
            return "Scan"
        case .track:
            return "Track"
        case .remind:
            return "Remind"
        case .share:
            return "Share"
        }
    }
    
    var description: String {
        switch self {
        case .scan:
            return "Scan any product barcode with easiest way."
        case .track:
            return "Track your proudects validity through colors."
        case .remind:
            return "Enable notification to get reminder in your chosen time."
        case .share:
            return "Share products details with any one to keep track of all expiry date products."
        }
    }
}


struct OnbordingView: View {
    
    @State var selectedOnbordingType: OnbordingType = .scan
    
    var body: some View {
        ZStack {
            
            if selectedOnbordingType != .share {
                VStack {
                    Text("skip")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing ,30)
                        .foregroundColor(.secondary)

                        .onTapGesture {
                            //MARK:
                        }
                    Spacer()
                }
            }
            
            TabView {
                
                ForEach(OnbordingType.allCases, id: \.title) { onbording in
                    SingleOnbording(onbordingType: onbording)
                        .onAppear{
                            selectedOnbordingType = onbording
                        }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
    }
}

struct OnbordingView_Previews: PreviewProvider {
    static var previews: some View {
        OnbordingView()
    }
}

struct SingleOnbording: View {
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
                }
                .font(.headline)
                .padding()
                .foregroundColor(.white)
                .frame(width: 300, height: 50)
                .background(Color("AccentColor"))
                .mask(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }

        }
        .padding(.horizontal,40)
        
        
    }
}

