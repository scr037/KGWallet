//
//  KGWallet.swift
//  KGWallet
//
//  Created by lchinigioli on 24/04/2021.
//

import UIKit
import Combine

public class KGWallet: UIView {
    private var cards: [KGCard]
    private var maxShowableCards: Int

    private var walletPublisker = PassthroughSubject<KGWallet.Action, Never>()
    private var cancelables: Set<AnyCancellable> = Set<AnyCancellable>()

    public var selectedCard: KGCard? {
        return cards.last
    }

    public init(
        cards: [KGCard],
        maxShowableCards: Int = 5
    ) {
        self.cards = cards
        self.maxShowableCards = maxShowableCards
        super.init(
            frame: CGRect(
                x: 0,
                y: 80,
                width: UIScreen.main.bounds.width,
                height: 200
            )
        )

        for card in cards {
            subscribe(to: card)
            self.addSubview(card)
        }
        
        arrangeContent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Public Wallet Interface
    
    public func add(card: KGCard) {
        defer { walletPublisker.send(.inFront(card)) }
        
        self.cards.append(card)
        self.subscribe(to: card)
        
        UIView.animate(
            withDuration: 0.3,
            animations: { [weak self] in
                self?.addSubview(card)
                self?.arrangeContent()
            }
        )
    }
    
    public func remove(card: KGCard) {
        UIView.animate(
            withDuration: 0.3,
            delay: 0.0,
            options: .curveEaseIn,
            animations: {
                card.removeFromSuperview()
            },
            completion: { _ in
                self.cards.removeAll(where: { $0 == card })
                self.arrangeContent()
                
                guard let frontCard = self.cards.last
                else { return }
                self.walletPublisker.send(.inFront(frontCard))
            }
        )
    }
    
    // MARK: Subscribe to wallet events
    
    public func subscribe(withCompletion completion: @escaping ((KGWallet.Action) -> Void)) {
        walletPublisker.sink { action in completion(action) }
            .store(in: &cancelables)
    }
    
    // MARK: Utility
    
    private func arrangeContent() {
        var offset = 0
        var zPosition: CGFloat = 0.0

        setCardsToInitialPosition()

        let drop = maxShowableCards > self.cards.count
            ? 0
            : self.cards.count - maxShowableCards

        cards.publisher
            .dropFirst(drop)
            .collect(.max)
            .sink { cards in
                for (index, card) in cards.enumerated() {
                    card.isHidden = false
                    card.center = CGPoint(
                        x: Int(self.center.x) - offset,
                        y: (Int(self.center.y) / 2) + offset
                    )
                    card.layer.zPosition = zPosition
                    card.isUserInteractionEnabled = false
                    offset += KGWallet.cardDistanceOffSet
                    zPosition += KGWallet.zPositionOffSet

                    if index == cards.count - 1 {
                        card.isUserInteractionEnabled = true
                    }
                }
            }
            .store(in: &cancelables)
    }
    
    private func setCardsToInitialPosition() {
        _ = cards.map {
            $0.isHidden = false
            $0.center = CGPoint(
                x: Int(self.center.x),
                y: (Int(self.center.y) / 2)
            )
        }
    }
    
    private func subscribe(to card: KGCard) {
        card.motionPublisher.sink(
            receiveValue: { action in
                switch action {
                case .swap:
                    self.didSwap(card: card)
                case .tap:
                    self.didTap(card: card)
                case .doubleTap:
                    self.didDoubleTap(card: card)
                }
            }
        )
        .store(in: &cancelables)
    }
}

// MARK: Events

extension KGWallet {
    
    public func flip(card: KGCard) {
        self.bringSubviewToFront(card)
        card.flip()
    }
}

// MARK: Handlers

extension KGWallet {
    
    func didSwap(card: KGCard) {
        func animateCardsRearrange(swappedCard: KGCard) {
            let position = self.cards.first?.frame.origin ?? CGPoint.zero
            swappedCard.frame = CGRect(origin: position, size: KGCard.standardSize)
            swappedCard.layer.zPosition = 0
            swappedCard.isUserInteractionEnabled = false

            guard let first = cards.popLast()
            else { return }
            cards.insert(first, at: 0)
            self.arrangeContent()
        }

        UIView.animateKeyframes(
            withDuration: 0.3,
            delay: 0.0,
            options: [ .calculationModeLinear],
            animations: {
                animateCardsRearrange(swappedCard: card)
            }, completion: { _ in
                guard let frontCard = self.cards.last else { return }
                self.walletPublisker.send(.inFront(frontCard))
            }
        )
    }
    
    func didTap(card: KGCard) {
        walletPublisker.send(.tapCard(card))
    }
    
    func didDoubleTap(card: KGCard) {
        walletPublisker.send(.doubleTapCard(card))
    }
}

// MARK: Actions

public extension KGWallet {
    
    enum Action {
        case inFront(_ card: KGCard)
        case tapCard(_ card: KGCard)
        case doubleTapCard(_ card: KGCard)
    }
}

// MARK: CONSTANTS

private extension KGWallet {
    static let cardDistanceOffSet = 5
    static let zPositionOffSet: CGFloat = 5.0
    static let maxCardsInStack = 3
    static var baseRotation = 0
    static let rotationOffSet = 5
}

// MARK: Utility

extension BinaryInteger {
    var degreesToRadians: CGFloat { return CGFloat(Int(self)) * .pi / 180 }
}
