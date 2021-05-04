//
//  ZLInputTextViewController.swift
//  ZLImageEditor
//
//  Created by long on 2020/10/30.
//
//  Copyright (c) 2020 Long Zhang <495181165@qq.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

class ZLInputTextViewController: UIViewController {

    static let collectionViewHeight: CGFloat = 50
    
    let image: UIImage?
    
    var text: String
    
    var cancelBtn: UIButton!
    
    var doneBtn: UIButton!
    
    var textView: UITextView!
    
    var collectionView: UICollectionView!
    
    var currentTextColor: UIColor
    
    var blurEffect = UIBlurEffect()
    
    var blurredEffectView = UIVisualEffectView()
    
    var collectionViewBottomConstraint = NSLayoutConstraint()
    
    /// text, textColor, bgColor
    var endInput: ( (String, UIColor, UIColor) -> Void )?
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .landscape]
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    init(image: UIImage?, text: String? = nil, textColor: UIColor? = nil, bgColor: UIColor? = nil) {
        self.image = image
        self.text = text ?? ""
        if let _ = textColor {
            self.currentTextColor = textColor!
        } else {
            if !ZLImageEditorConfiguration.default().textStickerTextColors.contains(ZLImageEditorConfiguration.default().textStickerDefaultTextColor) {
                self.currentTextColor = ZLImageEditorConfiguration.default().textStickerTextColors.first!
            } else {
                self.currentTextColor = ZLImageEditorConfiguration.default().textStickerDefaultTextColor
            }
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setUpConstraints()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIApplication.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIApplication.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.textView.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let index = ZLImageEditorConfiguration.default().textStickerTextColors.firstIndex(where: { $0 == self.currentTextColor}) {
            self.collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
    
    func setUpConstraints() {
        self.blurredEffectView.translatesAutoresizingMaskIntoConstraints = false
        self.blurredEffectView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.blurredEffectView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.blurredEffectView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.blurredEffectView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        let cancelBtnW = localLanguageTextValue(.cancel).boundingRect(font: ZLImageEditorLayout.bottomToolTitleFont, limitSize: CGSize(width: .greatestFiniteMagnitude, height: ZLImageEditorLayout.bottomToolBtnH)).width + 20
        self.cancelBtn.translatesAutoresizingMaskIntoConstraints = false
        self.cancelBtn.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor, constant: 10).isActive = true
        self.cancelBtn.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor, constant: 10).isActive = true
        self.cancelBtn.widthAnchor.constraint(equalToConstant: cancelBtnW).isActive = true
        self.cancelBtn.heightAnchor.constraint(equalToConstant: ZLImageEditorLayout.bottomToolBtnH).isActive = true
        
        let doneBtnW = localLanguageTextValue(.done).boundingRect(font: ZLImageEditorLayout.bottomToolTitleFont, limitSize: CGSize(width: .greatestFiniteMagnitude, height: ZLImageEditorLayout.bottomToolBtnH)).width + 20
        self.doneBtn.translatesAutoresizingMaskIntoConstraints = false
        self.doneBtn.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor, constant: 10).isActive = true
        self.doneBtn.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor, constant: -10).isActive = true
        self.doneBtn.widthAnchor.constraint(equalToConstant: doneBtnW).isActive = true
        self.doneBtn.heightAnchor.constraint(equalToConstant: ZLImageEditorLayout.bottomToolBtnH).isActive = true
        
        self.textView.translatesAutoresizingMaskIntoConstraints = false
        self.textView.topAnchor.constraint(equalTo: self.cancelBtn.bottomAnchor, constant: 10).isActive = true
        self.textView.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor, constant: 10).isActive = true
        self.textView.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor, constant: -10).isActive = true
        self.textView.bottomAnchor.constraint(equalTo: self.collectionView.topAnchor, constant: -10).isActive = true
        
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionViewBottomConstraint = self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        collectionViewBottomConstraint.isActive = true
        self.collectionView.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor, constant: 10).isActive = true
        self.collectionView.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor, constant: -10).isActive = true
        self.collectionView.heightAnchor.constraint(equalToConstant: ZLInputTextViewController.collectionViewHeight).isActive = true
    }
    
    func setupUI() {
        self.view.backgroundColor = .clear
        
        if #available(iOS 13.0, *) {
            blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        } else {
            blurEffect = UIBlurEffect(style: .dark)
        }
        blurredEffectView.effect = blurEffect
        blurredEffectView.frame = self.view.frame
        view.addSubview(blurredEffectView)
        
        self.cancelBtn = UIButton(type: .custom)
        self.cancelBtn.setTitle(localLanguageTextValue(.cancel), for: .normal)
        self.cancelBtn.titleLabel?.font = ZLImageEditorLayout.bottomToolTitleFont
        self.cancelBtn.addTarget(self, action: #selector(cancelBtnClick), for: .touchUpInside)
        view.addSubview(self.cancelBtn)
        
        self.doneBtn = UIButton(type: .custom)
        self.doneBtn.setTitle(localLanguageTextValue(.done), for: .normal)
        self.doneBtn.titleLabel?.font = ZLImageEditorLayout.bottomToolTitleFont
        self.doneBtn.addTarget(self, action: #selector(doneBtnClick), for: .touchUpInside)
        view.addSubview(self.doneBtn)
        
        self.textView = UITextView(frame: .zero)
        self.textView.keyboardAppearance = .dark
        self.textView.returnKeyType = .done
        self.textView.delegate = self
        self.textView.backgroundColor = .clear
        self.textView.tintColor = ZLImageEditorConfiguration.default().editDoneBtnBgColor
        self.textView.textColor = self.currentTextColor
        self.textView.text = self.text
        self.textView.font = UIFont.boldSystemFont(ofSize: ZLTextStickerView.fontSize)
        view.addSubview(self.textView)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 30, height: 30)
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 15
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        self.collectionView = UICollectionView(frame: CGRect(x: 0, y: self.view.frame.height - ZLInputTextViewController.collectionViewHeight, width: self.view.frame.width, height: ZLInputTextViewController.collectionViewHeight), collectionViewLayout: layout)
        self.collectionView.backgroundColor = .clear
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.showsHorizontalScrollIndicator = false
        self.view.addSubview(self.collectionView)
        
        ZLDrawColorCell.zl_register(self.collectionView)
    }
    
    @objc func cancelBtnClick() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func doneBtnClick() {
        self.endInput?(self.textView.text, self.currentTextColor, .clear)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(_ notify: Notification) {
        let rect = notify.userInfo?[UIApplication.keyboardFrameEndUserInfoKey] as? CGRect
        let keyboardH = rect?.height ?? 366
        let duration: TimeInterval = notify.userInfo?[UIApplication.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
        collectionViewBottomConstraint.constant = 0
        collectionViewBottomConstraint.constant -= keyboardH
        UIView.animate(withDuration: max(duration, 0.25)) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(_ notify: Notification) {
        let rect = notify.userInfo?[UIApplication.keyboardFrameEndUserInfoKey] as? CGRect
        let keyboardH = rect?.height ?? 366
        let duration: TimeInterval = notify.userInfo?[UIApplication.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
        
        collectionViewBottomConstraint.constant += keyboardH
        UIView.animate(withDuration: max(duration, 0.25)) {
            self.view.layoutIfNeeded()
        }
    }
    
}


extension ZLInputTextViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ZLImageEditorConfiguration.default().textStickerTextColors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLDrawColorCell.zl_identifier(), for: indexPath) as! ZLDrawColorCell
        
        let c = ZLImageEditorConfiguration.default().textStickerTextColors[indexPath.row]
        cell.color = c
        if c == self.currentTextColor {
            cell.bgWhiteView.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1)
        } else {
            cell.bgWhiteView.layer.transform = CATransform3DIdentity
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.currentTextColor = ZLImageEditorConfiguration.default().textStickerTextColors[indexPath.row]
        self.textView.textColor = self.currentTextColor
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        collectionView.reloadData()
    }
    
    
}


extension ZLInputTextViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            self.doneBtnClick()
            return false
        }
        return true
    }
    
}
