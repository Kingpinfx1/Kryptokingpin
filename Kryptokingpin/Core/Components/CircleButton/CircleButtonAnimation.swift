//
//  CircleButtonAnimation.swift
//  Kryptokingpin
//
//  Created by kingpin on 4/21/25.
//

import SwiftUI

struct CircleButtonAnimation: View {
    
    @Binding var animate: Bool
    
    var body: some View {
        Circle()
            .stroke(lineWidth: 5)
            .scale(animate ? 1.0 : 0)
            .opacity(animate ? 0.0 : 1.0)
            .animation( .easeInOut(duration: 1.0) , value: animate)
 
    }
}

#Preview {
    CircleButtonAnimation(animate: .constant(false))
        .frame(width: 100, height: 100)
}
