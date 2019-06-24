//
//  TextInputView.swift
//  VideoListModule
//
//  Created by Anton Boyarkin on 19/06/2019.
//

import UIKit
import IBACore
import FlexLayout
import PinLayout

public class TextInputView: UIView {
    public let nameField = UITextField()
    public let commentField = UITextField()
    public let submitButton = UIButton(type: .custom)
    
    var onSubmit: ((_ name: String, _ text: String) -> Void)?
    
    private let colorScheme: ColorSchemeModel
    
    init(colorScheme: ColorSchemeModel) {
        self.colorScheme = colorScheme
        super.init(frame: .zero)
        
        backgroundColor = .white
        
        nameField.placeholder = Localization.Common.Text.name
        nameField.font = .systemFont(ofSize: 14)
        
        commentField.placeholder = Localization.Common.Text.message
        commentField.font = .systemFont(ofSize: 14)
        
        submitButton.setTitle(Localization.Common.Text.send, for: .normal)
        submitButton.setTitleColor(colorScheme.textColor, for: .normal)
        submitButton.titleLabel?.font = .systemFont(ofSize: 14)
        submitButton.sizeToFit()
        
        flex.direction(.row).padding(8).define { flex in
            flex.addItem().direction(.column).grow(1).define({ flex in
                flex.addItem(nameField).height(30)
                flex.addItem(commentField).height(30)
            })
            flex.addItem(submitButton).marginLeft(8)
        }
        
        submitButton.addTarget(self, action: #selector(submit), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        flex.layout(mode: .adjustHeight)
    }
    
    @objc func submit() {
        onSubmit?(nameField.text ?? "", commentField.text ?? "")
        nameField.text = ""
        commentField.text = ""
        
        nameField.resignFirstResponder()
        commentField.resignFirstResponder()
    }
}
