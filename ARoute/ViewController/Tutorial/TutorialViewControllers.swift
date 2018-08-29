import UIKit

class BaseViewController: UIViewController {
    
    @IBOutlet var skipButton: UIButton!
    
    @objc func didtapSkip() {
        dismiss(animated: true, completion: nil)
    }
}

class Page1ViewController: BaseViewController {
    
    @IBOutlet var startButton: UIButton!
    
    override func viewDidLoad() {
        skipButton.addTarget(self, action: #selector(didtapSkip), for: .touchUpInside)
        startButton.addTarget(self, action: #selector(didtapStart), for: .touchUpInside)
        startButton.layer.cornerRadius = startButton.frame.height / 2
        startButton.layer.masksToBounds = true
    }
    
    @objc func didtapStart() {
        let pageController = self.parent as! PageViewController
        pageController.setViewControllers([pageController.pages[1]], direction: .forward, animated: true, completion: nil)
        pageController.pageControl.currentPage = 1
    }
}

class Page2ViewController: BaseViewController {
    override func viewDidLoad() {
        skipButton.addTarget(self, action: #selector(didtapSkip), for: .touchUpInside)
    }
}
class Page3ViewController: BaseViewController {
    override func viewDidLoad() {
        skipButton.addTarget(self, action: #selector(didtapSkip), for: .touchUpInside)
    }
}
class Page4ViewController: BaseViewController {
    
    @IBOutlet var startButton: UIButton!
    
    override func viewDidLoad() {
        skipButton.addTarget(self, action: #selector(didtapSkip), for: .touchUpInside)
        startButton.addTarget(self, action: #selector(didtapSkip), for: .touchUpInside)
        startButton.layer.cornerRadius = startButton.frame.height / 2
        startButton.layer.masksToBounds = true
    }
}
