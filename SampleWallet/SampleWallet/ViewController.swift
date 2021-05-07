//
//  ViewController.swift
//  SampleWallet
//
//  Created by lchinigioli on 24/04/2021.
//

import UIKit
import KGWallet

class ViewController: UIViewController {

    private var wallet: KGWallet?

    override func viewDidLoad() {
        super.viewDidLoad()

        // WALLET

        let card1 = KGCard(
            frame: KGCard.standardFrame,
            type: .singleTitle("Swipe to learn more!"),
            background: .color(color: .blue)
        )
        let card2 = KGCard(
            frame: KGCard.standardFrame,
            type: .title("Got it?", subtitle: "Now you can add your own cards!"),
            background: .color(color: .red)
        )
        let card3 = KGCard(
            frame: KGCard.standardFrame,
            type: .payment(
                cardnumber: "••••-••••-••••-1234",
                expiration: "12/29",
                cvv: "321",
                holder: "John Doe",
                icon: UIImage.init(named: "visa_new") ?? UIImage()
            ),
            background: .color(color: .black)
        )
        let card4 = KGCard(
            frame: KGCard.standardFrame,
            type: .payment(
                cardnumber: "••••-••••-••••-4567",
                expiration: "01/25",
                cvv: "123",
                holder: "John Doe",
                icon: UIImage.init(named: "visa_new") ?? UIImage()
            ),
            background: .color(color: .darkGray)
        )
        let wallet = KGWallet(cards: [card4, card3, card2, card1])
        self.wallet = wallet
        
        self.wallet?.subscribe(withCompletion: { action in
            switch action {
            case let .inFront(card):
                // You can update screen status based
                // on the kind of card you're seeing.
                print("inFront \(card)")
            case let .tapCard(card):
                // Cards can be tapped.
                print("tapCard \(card)")
            case let .doubleTapCard(card):
                // if you double tap, something cool can
                card.flip()
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // STACK VIEW
        
        let stackView = UIStackView(frame: UIScreen.main.bounds)
        stackView.axis = .vertical
        self.view.addSubview(stackView)

        if let wallet = self.wallet {
            stackView.addArrangedSubview(wallet)
        }
        
        // Buttons stack
        
        let buttonsStack = UIStackView()
        buttonsStack.axis = .horizontal
        buttonsStack.distribution = .fillEqually
        buttonsStack.alignment = .center
       
        // ADD button
        let addButton = UIButton()
        addButton.backgroundColor = .black
        addButton.setTitle("Add card!", for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        addButton.addTarget(self, action: #selector(addCard), for: .touchUpInside)
        buttonsStack.addArrangedSubview(addButton)
        
        let removeButton = UIButton()
        removeButton.backgroundColor = .red
        removeButton.setTitle("Remove card!", for: .normal)
        removeButton.setTitleColor(.white, for: .normal)
        removeButton.addTarget(self, action: #selector(removeCard), for: .touchUpInside)
        buttonsStack.addArrangedSubview(removeButton)
        
        stackView.addArrangedSubview(buttonsStack)
    }
}

extension ViewController {
    static var title = 1
    
    @objc func addCard() {
        defer { ViewController.title += 1 }
        
        let card = getRandomCard()
        wallet?.add(card: card)
    }
    
    @objc func removeCard() {
        if let card = wallet?.selectedCard {
            wallet?.remove(card: card)
        }
    }
    
    func getRandomCard() -> KGCard {
        return KGCard(
            frame: KGCard.standardFrame,
            type: .title("\(Self.title)", subtitle: "You've added \(Self.title) card(s) already"),
            background: .color(color: .random())
        )
    }
}

extension UIColor {
    
    static func random() -> UIColor {
        return UIColor(
            red:   .random(in: 0...1),
            green: .random(in: 0...1),
            blue:  .random(in: 0...1),
            alpha: 1.0
        )
    }
}

