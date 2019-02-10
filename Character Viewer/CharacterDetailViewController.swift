//
//  CharacterDetailViewController.swift
//  Character Viewer
//
//  Created by ANTHONY O. on 1/29/19.
//  Copyright © 2019 ANTHONY O. All rights reserved.
//

import UIKit

class CharacterDetailViewController: UIViewController {
    
    @IBOutlet weak var characterImageView: UIImageView!
    @IBOutlet weak var characterTitleLabel: UILabel!
    @IBOutlet weak var characterDescriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateDetailView()        
    }
    
    func updateDetailView() {
        if !filteredcharacterListArray.isEmpty {
            if let dict = filteredcharacterListArray[characterIndex] as? Character {
                if let titleAndDescription = dict.Text, let endIndex = titleAndDescription.range(of: "-")?.lowerBound {
                    characterTitleLabel?.text = String(titleAndDescription[..<endIndex])
                    characterDescriptionLabel?.text = String(titleAndDescription[endIndex...])
                    self.title = String(titleAndDescription[..<endIndex])
                }
                if let imageDict = dict.Icon, let url = URL(string: (imageDict.URL)!) {
                    if let imageFromCache = imageCache.object(forKey: imageDict.URL as AnyObject) {
                        characterImageView?.image = UIImage(data: imageFromCache as! Data)
                    } else {
                    DispatchQueue.global(qos: .userInitiated).async {
                        if let imageData = try? Data(contentsOf: url) {
                            imageCache.setObject(imageData as AnyObject, forKey: imageDict.URL as AnyObject)
                            DispatchQueue.main.async { [weak self] in
                                self?.characterImageView?.image = UIImage(data: imageData)
                            }}}}} else {
                    #if TheWire
                    characterImageView?.image = UIImage(named: "TheWire")
                    #else
                    characterImageView?.image = UIImage(named: "TheSimpsons")
                    #endif
                }}}}
    
}
