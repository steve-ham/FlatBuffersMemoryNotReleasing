import UIKit
import FlatBuffers

public struct ACC {
    let reqId: String
    let msTime: Int
    let nsTimestamp: Int
    let x: Double
    let y: Double
    let z: Double
    
    init(reqId: String, ms: Double, x: Double, y: Double, z: Double) {
        self.reqId = reqId
        let ns = ms * 1_000_000
        msTime = Int(ms)
        nsTimestamp = Int(ns)
        self.x = x
        self.y = y
        self.z = z
    }
}

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add a button to trigger FlatBuffers serialization
        let button = UIButton(type: .system)
        button.setTitle("Run FlatBuffers Test", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 22)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(runFlatBuffersTest), for: .touchUpInside)
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private var b: FlatBufferBuilder? = FlatBufferBuilder()
    
    @objc func runFlatBuffersTest() {
        // Minimal reproducible FlatBuffers serialization
        var accs: [ACC] = []
        accs.reserveCapacity(1_000_000)
        for i in 0..<1_000_000 {
            accs.append(ACC(reqId: "id\(i)", ms: Double(i), x: Double(i), y: Double(i), z: Double(i)))
        }
        
        var offsets = [Offset]()
        offsets.reserveCapacity(accs.count)
        for acc in accs {
            let reqId = b!.create(string: acc.reqId)
            let start = FBACC.startFBACC(&b!)
            FBACC.add(reqId: reqId, &b!)
            FBACC.add(msTime: Int64(acc.msTime), &b!)
            FBACC.add(nsTimestamp: Int64(acc.nsTimestamp), &b!)
            FBACC.add(x: acc.x, &b!)
            FBACC.add(y: acc.y, &b!)
            FBACC.add(z: acc.z, &b!)
            let end = FBACC.endFBACC(&b!, start: start)
            offsets.append(end)
        }
        let vector = b!.createVector(ofOffsets: offsets)
        let accsOffset = FBACCs.createFBACCs(&b!, accsVectorOffset: vector)
        b!.finish(offset: accsOffset)
        let result = b!.data
        b!.clear()
        b = nil
        print("b: \(b)")
        print("FlatBuffer result size: \(result.count) bytes")
    }
}
