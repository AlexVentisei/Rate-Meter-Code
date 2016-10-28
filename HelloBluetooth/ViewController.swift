import UIKit

class ViewController: UIViewController {
    var StrokeMeter: StrokeMeterIO!


    @IBOutlet weak var xValueLabel: UILabel!
    @IBOutlet weak var yValueLabel: UILabel!
    @IBOutlet weak var zValueLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        StrokeMeter = StrokeMeterIO(serviceUUID: "e95d0753-251d-470a-a062-fa1922dfa9a8", delegate: self)
    }


}

extension ViewController: StrokeMeterIODelegate {
    func didReceiveValue(_ StrokeMeterIO: StrokeMeterIO, value_x: Int16, value_y: Int16, value_z: Int16) {
    
        xValueLabel.text = String(value_x)
        yValueLabel.text = String(value_y)
        zValueLabel.text = String(value_z)
    
    }
}
