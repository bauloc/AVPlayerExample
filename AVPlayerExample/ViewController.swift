//
//  ViewController.swift
//  AVPlayerExample
//
//  Created by BAU LOC on 8/8/20.
//  Copyright © 2020 BAULOC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var txtURL: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func tapPlayURL(_ sender: UIButton) {
        
        let url_text = txtURL.text ?? ""
        let player = PlayerViewController.instantiate()
        player.reloadStream(source_url: url_text, title: url_text)
        present(player, animated: true, completion: nil)
        
    }
    
    @IBAction func tapPlayLocal(_ sender: UIButton) {
        
        if let filepath = Bundle.main.path(forResource: "BAULOC", ofType: "mov") {
            let url = URL(fileURLWithPath: filepath)
            let player = PlayerViewController.instantiate()
            player.reloadStream(source_url: url.absoluteString, title: "Độ ta không độ nàng")
            present(player, animated: true, completion: nil)
        }
        
    }
}

