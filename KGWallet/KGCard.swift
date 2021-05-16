//
//  KGCard.swift
//  KGWallet
//
//  Created by lchinigioli on 24/04/2021.
//

import UIKit
import Combine

public class KGCard: UIView {
    public static let origin = CGPoint(x: 0, y: 0)
    public static let standardSize = CGSize(width: 280, height: 200)
    public static let standardFrame = CGRect(origin: origin, size: standardSize)
    
    var translation: CGPoint?
    var originalFrame: CGRect?
    
    var motionPublisher = PassthroughSubject<KGCard.Action, Never>()

    var front: UIView!
    var back: UIView!
    
    public init(
        frame: CGRect,
        type: CardType,
        background: KGCard.Background
    ) {
        super.init(frame: frame)
        configureFrontSide(frame: frame)
        configureBackSide(frame: frame)
        configureCard(background: background)
        drawCard(type: type)
        setupGestureHandlers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: OBJC Selectors
    
    @objc func didTap() {
        motionPublisher.send(.tap)
    }
    
    @objc func didDoubleTap() {
        motionPublisher.send(.doubleTap)
    }
    
    // MARK: Private
    
    private func configureFrontSide(frame: CGRect) {
        front = UIView(frame: frame)
        front.backgroundColor = .clear
        front.isUserInteractionEnabled = false
        addSubview(front)
        
    }
    
    private func configureBackSide(frame: CGRect) {
        back = UIView(frame: frame)
        back.isHidden = true
        back.backgroundColor = .clear
        back.isUserInteractionEnabled = false
        addSubview(back)
    }
    
    private func drawCard(type: CardType) {
        switch type {
        case let .singleTitle(text):
            drawSingleTextCard(text)
        case let .title(title, subtitle):
            drawTitleSubtitleCard(title, subtitle)
        case let .payment(cardnumber, expiration, cvv, holder, icon):
            drawPaymentCard(
                cardNumber: cardnumber,
                expiration: expiration,
                cvv: cvv,
                cardholder: holder,
                icon: icon
            )
        }
    }
    
    private func drawSingleTextCard(_ text: String) {
        let label = UILabel(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: 20))
        label.text = text
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.textColor = .white
        
        let stackView = UIStackView(frame: self.frame)
        stackView.axis = .horizontal
        stackView.addArrangedSubview(label)
        stackView.isUserInteractionEnabled = false
        
        front.addSubview(stackView)
    }
    
    private func drawTitleSubtitleCard(_ title: String, _ subtitle: String) {
        let titleLabel = UILabel(
            frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: 20)
        )
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        titleLabel.textColor = .white
        
        let subtitleLabel = UILabel(
            frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: 20)
        )
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 10, weight: .regular)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textColor = .white
        
        let stackView = UIStackView(frame: self.frame)
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = true
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.isUserInteractionEnabled = false
        
        front.addSubview(stackView)
    }
    
    private func drawPaymentCard(
        cardNumber: String,
        expiration: String,
        cvv: String,
        cardholder: String,
        icon: UIImage?
    ) {
        let contentStack = UIStackView(frame: self.frame)
        contentStack.axis = .horizontal
        contentStack.isUserInteractionEnabled = false
        
        let cardNumberLabel = UILabel(
            frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: 20)
        )
        cardNumberLabel.text = cardNumber
        cardNumberLabel.font = .systemFont(ofSize: 12, weight: .medium)
        cardNumberLabel.textAlignment = .center
        cardNumberLabel.numberOfLines = 1
        cardNumberLabel.textColor = .white
        
        let cardholderLabel = UILabel(
            frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: 20)
        )
        cardholderLabel.text = cardholder
        cardholderLabel.font = .systemFont(ofSize: 10, weight: .regular)
        cardholderLabel.textAlignment = .center
        cardholderLabel.numberOfLines = 1
        cardholderLabel.textColor = .white
        
        let expirationLabel = UILabel(
            frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: 20)
        )
        expirationLabel.text = expiration
        expirationLabel.font = .systemFont(ofSize: 11, weight: .regular)
        expirationLabel.textAlignment = .center
        expirationLabel.numberOfLines = 1
        expirationLabel.textColor = .white
        
        let dataStackView = UIStackView()
        dataStackView.axis = .vertical
        dataStackView.distribution = .fillEqually
        dataStackView.translatesAutoresizingMaskIntoConstraints = true
        dataStackView.isUserInteractionEnabled = false
        dataStackView.addArrangedSubview(cardNumberLabel)
        dataStackView.addArrangedSubview(expirationLabel)
        dataStackView.addArrangedSubview(cardholderLabel)
        
        contentStack.addArrangedSubview(dataStackView)
        
        front.addSubview(contentStack)
        
        let cvvLabel = UILabel(
            frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: 20)
        )
        cvvLabel.text = "CVV: \(cvv)"
        cvvLabel.font = .systemFont(ofSize: 8, weight: .regular)
        cvvLabel.textAlignment = .center
        cvvLabel.numberOfLines = 1
        cvvLabel.textColor = .white
        
        let backStackView = UIStackView(frame: self.frame)
        backStackView.axis = .vertical
        backStackView.distribution = .fillEqually
        backStackView.translatesAutoresizingMaskIntoConstraints = true
        backStackView.isUserInteractionEnabled = false
        backStackView.addArrangedSubview(cvvLabel)
        
        back.addSubview(backStackView)
    }
    
    private func configureCard(background: Background) {
        self.backgroundColor = background.color
        self.layer.cornerRadius = 4
    }
    
    private func setupGestureHandlers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        self.addGestureRecognizer(tapGesture)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTap)
        
        tapGesture.require(toFail: doubleTap)
    }
    
    private func restoreOriginalPosition() {
        UIView.animate(
            withDuration: 0.2,
            animations: {
                self.frame = self.originalFrame ?? CGRect.zero
            }
        )
    }
    
    private func pop() {
        UIView.animate(
            withDuration: 0.2,
            delay: 0.0,
            options: .curveEaseInOut,
            animations: {
                self.transform = CGAffineTransform.init(scaleX: 1.1, y: 1.1)
            }, completion: nil
        )
    }
    
    private func reset() {
        UIView.animate(
            withDuration: 0.1,
            delay: 0.0,
            options: .curveEaseInOut,
            animations: {
                self.transform = CGAffineTransform.identity
            }, completion: nil
        )
    }
    
    // MARK: Touch handlers
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if touch?.view == self {
            translation = touch?.location(in: self.superview)
        }
        
        self.originalFrame = self.frame
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if touch?.view == self {
            let newTranslation = touch?.location(in: self.superview)
            
            guard
                let translationX = self.translation?.x,
                let translationY = self.translation?.y,
                let newTranslationX = newTranslation?.x,
                let newTranslationY = newTranslation?.y
            else { restoreOriginalPosition(); return }
            
            self.pop()
            self.frame = self.frame.offsetBy(
                dx: newTranslationX - translationX,
                dy: newTranslationY - translationY
            )
            self.translation = newTranslation
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        reset()
        
        guard let translationY = self.translation?.y
        else { restoreOriginalPosition(); return }
        
        if touch?.view == self
            && (translationY > CGFloat(KGCard.translationMove) || translationY < CGFloat(KGCard.translationMoveUp)
        ) {
            motionPublisher.send(.swap)
        } else {
            restoreOriginalPosition()
        }
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        reset()
        restoreOriginalPosition()
    }
}

// MARK: Actions

public extension KGCard {
    enum Action {
        case swap
        case tap
        case doubleTap
    }
}

// MARK: Constants

private extension KGCard {
    static let translationMove = 200.0
    static let translationMoveUp = 50.0
}

// MARK: Configuration

public extension KGCard {
    
    enum Background {
        case color(color: UIColor)
        case image(url: String)
        
        var color: UIColor {
            switch self {
            case let .color(color):
                return color
            default:
                return .white
            }
        }
    }
}

// MARK: Utility

public extension KGCard {
    
    override var description: String {
        get {
            "\(self.backgroundColor?.accessibilityName ?? "unknown") card"
        }
    }
}

// MARK: Style

public enum CardType {
    case singleTitle(_ text: String)
    case title(_ text: String, subtitle: String)
    case payment(
            cardnumber: String,
            expiration: String,
            cvv: String,
            holder: String,
            icon: UIImage
         )
}

// MARK: Actions

public extension KGCard {
    private static var isFlipped = false

    func flip() {
        UIView.transition(
            with: self,
            duration: 0.3,
            options: .transitionFlipFromRight,
            animations: { [weak self] in
                guard let self = self else { return }
                self.front.isHidden = !Self.isFlipped
                self.back.isHidden = Self.isFlipped
                
                Self.isFlipped = !Self.isFlipped
            },
            completion: nil
        )
    }
}
