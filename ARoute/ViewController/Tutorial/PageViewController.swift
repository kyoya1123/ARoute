import UIKit

class PageViewController: UIPageViewController {
    
    var pages = [UIViewController]()
    var pageControl: UIPageControl!

    override func viewDidLoad() {
        readyViewControllers()
        setupPageControl()
        view.addSubview(pageControl)
        setViewControllers([pages[0]], direction: .forward, animated: true, completion: nil)
        self.dataSource = self
    }
    
    func readyViewControllers() {
        pages = [
        storyboard!.instantiateViewController(withIdentifier: "Page1ViewController") as! Page1ViewController,
        storyboard!.instantiateViewController(withIdentifier: "Page2ViewController") as! Page2ViewController,
        storyboard!.instantiateViewController(withIdentifier: "Page3ViewController") as! Page3ViewController,
        storyboard!.instantiateViewController(withIdentifier: "Page4ViewController") as! Page4ViewController
        ]
    }
    
    func setupPageControl() {
        pageControl = UIPageControl(frame: CGRect(x: 0, y: view.frame.height - 60, width: view.frame.width, height: 40))
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.isUserInteractionEnabled = false
    }
}

extension PageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        pageControl.currentPage = viewController.view.tag
        if viewController.isKind(of: Page4ViewController.self) {
            return pages[2]
        } else if viewController.isKind(of: Page3ViewController.self) {
            return pages[1]
        } else if viewController.isKind(of: Page2ViewController.self) {
            return pages[0]
        } else {
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        pageControl.currentPage = viewController.view.tag
        if viewController.isKind(of: Page1ViewController.self) {
            return pages[1]
        } else if viewController.isKind(of: Page2ViewController.self) {
            return pages[2]
        } else if viewController.isKind(of: Page3ViewController.self) {
            return pages[3]
        } else {
            return nil
        }
    }
}
