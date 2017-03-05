import UIKit
import Foundation

@available(iOS 10.0, *)
class ViewController: UIViewController {
    
    var StrokeMeter: StrokeMeterIO!
    var xSmooth: [Int16] = []
    var ySmooth: [Int16] = []
    var zSmooth: [Int16] = []
    var smoothCount: Int = 25
    var forceTriggerPoint = 300.0
    var strokeTimePoint1 = Date()
    var strokeTimePoint2 = Date()
    var strokeInterval = TimeInterval()
    var lastResultantForce: Double = 0.0
    


    @IBOutlet weak var xValueLabel: UILabel!
    @IBOutlet weak var yValueLabel: UILabel!
    @IBOutlet weak var zValueLabel: UILabel!
    @IBOutlet weak var resultantForceLabel: UILabel!
    @IBOutlet weak var strokeRateLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()


        StrokeMeter = StrokeMeterIO(delegate: self)
    }


}

@available(iOS 10.0, *)
extension ViewController: StrokeMeterIODelegate {
    func didReceiveValue(_ StrokeMeterIO: StrokeMeterIO, value_x: Int16, value_y: Int16, value_z: Int16) {
        
        
        xSmooth.append(value_x)
        ySmooth.append(value_y)
        zSmooth.append(value_z)
        var resultantForce = 0.0
        
        if xSmooth.count > smoothCount{
            xSmooth.remove(at: 0)
            ySmooth.remove(at: 0)
            zSmooth.remove(at: 0)
        }
        
        var xSum = 0.0
        var xAverage = 0.0
        
        for x in xSmooth {
            xSum += Double(x)
        }
        xAverage = xSum/Double(xSmooth.count)
        
        var ySum = 0.0
        var yAverage = 0.0
        
        for y in ySmooth {
            ySum += Double(y)
        }
        yAverage = ySum/Double(ySmooth.count)
        
        var zSum = 0.0
        var zAverage = 0.0
        
        for z in zSmooth {
            zSum += Double(z)
        }
        zAverage = zSum/Double(zSmooth.count)
        
        xValueLabel.text = String(format: "%.0f", xAverage)
        yValueLabel.text = String(format: "%.0f", yAverage)
        zValueLabel.text = String(format: "%.0f", zAverage)
        
        resultantForce = sqrt(pow(xAverage,2) + pow(yAverage,2))
     //   let deltaForce = lastResultantForce - resultantForce
     //   resultantForceLabel.text = String(format: "%.0f", resultantForce)
        
        if resultantForce > forceTriggerPoint {
            strokeTimePoint2 = Date()
            strokeInterval = strokeTimePoint2.timeIntervalSince(strokeTimePoint1)
            if strokeInterval > Double(1) {
                let strokeRate = 60/strokeInterval
                strokeTimePoint1 = Date()
                strokeRateLabel.text = String(format: "%.1f", strokeRate)
                StrokeMeter.writePinValue(strokeRate: strokeRate);
            }
        }
        lastResultantForce = resultantForce
      
        
    }
}
