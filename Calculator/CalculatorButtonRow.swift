//
//  CalculatorButtonRow.swift
//  Calculator
//
//  Created by macmac on 2022/9/25.
//

import SwiftUI

struct CalculatorButtonRow: View {
    let screenWidth: CGFloat
    let spacing: CGFloat
    let buttons: [CalculatorButton]
    
    private func getButtonGridSize() -> CGFloat {
        return (self.screenWidth - self.spacing * 5) / 4
    }
    
    private func getButtonWidth(title: String) -> CGFloat {
        return title != "0" ? getButtonGridSize() : getButtonGridSize() * 2 + self.spacing
    }
    
    var didTapButton: (CalculatorButton) -> ()
    
    
    var body: some View {
        HStack{
            ForEach(self.buttons) { button in
                Button(action: {
                    //print("Button \(button.title) tapped.")
                    self.didTapButton(button)
                }) {
                    Text(button.title)
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                        .frame(width: self.getButtonWidth(title: button.title),
                               height: self.getButtonGridSize())
                        .background(button.color)
                        .cornerRadius(100)
                }
            }
        }
        
    }
}


struct CalculatorButtonRow_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            CalculatorButtonRow(screenWidth: geometry.size.width,
                                spacing: 12, buttons: buttonRows[0],
                                didTapButton: {button in print("Button \(button.title) tapped.")})
        }
    }
}
