import UIKit

class BaseViewController: UIViewController {
    
    @IBOutlet var skipButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    
    @objc func didtapSkip() {
        dismiss(animated: true, completion: nil)
    }
    
    func setupLabels(title: String, description: String) {
        titleLabel.text = title
        descriptionLabel.text = description
    }
}

class Page1ViewController: BaseViewController {
    
    @IBOutlet var startButton: UIButton!
    
    override func viewDidLoad() {
        skipButton.setTitle(NSLocalizedString("skip", comment: ""), for: .normal)
        skipButton.addTarget(self, action: #selector(didtapSkip), for: .touchUpInside)
        startButton.setTitle(NSLocalizedString("page1Button", comment: ""), for: .normal)
        startButton.addTarget(self, action: #selector(didtapStart), for: .touchUpInside)
        startButton.layer.cornerRadius = startButton.frame.height / 2
        startButton.layer.masksToBounds = true
        setupLabels(title: NSLocalizedString("page1Title", comment: ""), description: NSLocalizedString("page1Description", comment: ""))
    }
    
    @objc func didtapStart() {
        let pageController = self.parent as! PageViewController
        pageController.setViewControllers([pageController.pages[1]], direction: .forward, animated: true, completion: nil)
        pageController.pageControl.currentPage = 1
    }
}

class Page2ViewController: BaseViewController {
    override func viewDidLoad() {
        skipButton.setTitle(NSLocalizedString("skip", comment: ""), for: .normal)
        skipButton.addTarget(self, action: #selector(didtapSkip), for: .touchUpInside)
        setupLabels(title: NSLocalizedString("page2Title", comment: ""), description: NSLocalizedString("page2Description", comment: ""))
    }
}
class Page3ViewController: BaseViewController {
    override func viewDidLoad() {
        skipButton.setTitle(NSLocalizedString("skip", comment: ""), for: .normal)
        skipButton.addTarget(self, action: #selector(didtapSkip), for: .touchUpInside)
        setupLabels(title: NSLocalizedString("page3Title", comment: ""), description: NSLocalizedString("page3Description", comment: ""))
    }
}
class Page4ViewController: BaseViewController {
    
    @IBOutlet var startButton: UIButton!
    @IBOutlet var notificationTitle: UILabel!
    @IBOutlet var notificationMessage: UILabel!
    
    override func viewDidLoad() {
        skipButton.setTitle(NSLocalizedString("skip", comment: ""), for: .normal)
        skipButton.addTarget(self, action: #selector(didtapSkip), for: .touchUpInside)
        startButton.setTitle(NSLocalizedString("page4Button", comment: ""), for: .normal)
        startButton.addTarget(self, action: #selector(didtapSkip), for: .touchUpInside)
        startButton.layer.cornerRadius = startButton.frame.height / 2
        startButton.layer.masksToBounds = true
        setupLabels(title: NSLocalizedString("page4Title", comment: ""), description: NSLocalizedString("page4Description", comment: ""))
        notificationTitle.text = NSLocalizedString("notificationTitle", comment: "")
        notificationMessage.text = NSLocalizedString("page4Notification", comment: "")
    }
}
