//
//  ContentView.swift
//  Calculator
//
//  Created by macmac on 2022/9/25.
//


import SwiftUI

class CalculatorViewModel: ObservableObject {
    static let defaultDisplay = "0"
    @Published var display = CalculatorViewModel.defaultDisplay
    @Published var sequence = ""
    
    let numberFormatter = NumberFormatter()
    private var brain = CalculatorBrain()
    
    init() {
        numberFormatter.numberStyle = .decimal
        numberFormatter.usesGroupingSeparator = false
        numberFormatter.maximumFractionDigits = 6
        brain.numberFormatter = numberFormatter
    }
    
    var displayValue: Double {
        get {
            return Double(display)!
        }
        set {
            display = numberFormatter.string(from: NSNumber(value: newValue))!
        }
    }
    
    var userIsInMiddleOfTyping = false
    
    func buttonTapped(button: CalculatorButton) {
        switch button.title {
        case "AC":
            brain.reset()
            userIsInMiddleOfTyping = false
            display = CalculatorViewModel.defaultDisplay
            sequence = ""
        case "0"..."9":
            if userIsInMiddleOfTyping {
                display = display + button.title
            } else {
                display = button.title
                userIsInMiddleOfTyping = true
            }
            
        case ".":
            if userIsInMiddleOfTyping {
                if !display.contains(".") {
                    display = display + "."
                }
            } else {
                display = "0."
                userIsInMiddleOfTyping = true
            }
            
        default: // all remain buttons are operators
            if userIsInMiddleOfTyping {
                brain.setOperand(displayValue)
                userIsInMiddleOfTyping = false
            }
            
            brain.performOperation(button.title)
            
            if let result = brain.result.value {
                displayValue = result
            }
            
            let resultStateIndicator = brain.resultIsPending ? "..." : "="
            sequence = "\(brain.result.description) \(resultStateIndicator)"
        }
    }
}


struct CalculatorView: View {
    let spacing: CGFloat = 12
    @ObservedObject var vm = Calculator .CalculatorViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .center, spacing: self.spacing) {
                    Spacer()
                    
                    HStack{
                        Spacer()
                        Text(self.vm.display)
                            .font(.system(size: 74))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.trailing)
                    }.padding(.horizontal, self.spacing)
                    
                    HStack{
                        Spacer()
                        Text(self.vm.sequence)
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.trailing)
                    }.padding(.horizontal, self.spacing)
                    
                    ForEach(buttonRows, id: \.self) { buttonRow in
                        CalculatorButtonRow(
                            screenWidth: geometry.size.width,
                            spacing: self.spacing,
                            buttons: buttonRow,
                            didTapButton: { button in self.vm.buttonTapped(button: button)
                                
                            })
                    }
                }
            }
        }
    }
}

struct CalculatorView_Previews: PreviewProvider {
    static var previews: some View {
            CalculatorView()
    }
}
