//
//  LogoShape.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/13/22.
//

import Foundation
import SwiftUI

struct ShapeView: Shape {
    let bezier: UIBezierPath

    func path(in rect: CGRect) -> Path {
        let path = Path(bezier.cgPath)
        let multiplier = min(rect.width, rect.height)
        let transform = CGAffineTransform(scaleX: multiplier, y: multiplier)
        return path.applying(transform)
    }
}

extension UIBezierPath {
    static var rdLogo: UIBezierPath {
        let multiplier = 1.5
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0.363 * multiplier, y: 0.1499 * multiplier))
        path.addCurve(to: CGPoint(x: 0.3114 * multiplier, y: 0.1508 * multiplier), controlPoint1: CGPoint(x: 0.3352 * multiplier, y: 0.150 * multiplier), controlPoint2: CGPoint(x: 0.3114 * multiplier, y: 0.1508 * multiplier))
        path.addCurve(to: CGPoint(x: 0.081 * multiplier, y: 0.3151 * multiplier), controlPoint1: CGPoint(x: 0.3114 * multiplier, y: 0.1508 * multiplier), controlPoint2: CGPoint(x: 0.1014 * multiplier, y: 0.1502 * multiplier))
        path.addCurve(to: CGPoint(x: 0.1643 * multiplier, y: 0.4813 * multiplier), controlPoint1: CGPoint(x: 0.0713 * multiplier, y: 0.3938 * multiplier), controlPoint2: CGPoint(x: 0.1094 * multiplier, y: 0.4485 * multiplier))
        path.addCurve(to: CGPoint(x: 0.3084 * multiplier, y: 0.5189 * multiplier), controlPoint1: CGPoint(x: 0.2071 * multiplier, y: 0.5069 * multiplier), controlPoint2: CGPoint(x: 0.2601 * multiplier, y: 0.5183 * multiplier))
        path.addCurve(to: CGPoint(x: 0.3568 * multiplier, y: 0.5206 * multiplier), controlPoint1: CGPoint(x: 0.3191 * multiplier, y: 0.519 * multiplier), controlPoint2: CGPoint(x: 0.3461 * multiplier, y: 0.5214 * multiplier))
        path.addLine(to: CGPoint(x: 0.3572 * multiplier, y: 0.1871 * multiplier))
        path.addCurve(to: CGPoint(x: 0.4134 * multiplier, y: 0.1879 * multiplier), controlPoint1: CGPoint(x: 0.3572 * multiplier, y: 0.1871 * multiplier), controlPoint2: CGPoint(x: 0.3949 * multiplier, y: 0.1868 * multiplier))
        path.addCurve(to: CGPoint(x: 0.4868 * multiplier, y: 0.2546 * multiplier), controlPoint1: CGPoint(x: 0.4173 * multiplier, y: 0.1882 * multiplier), controlPoint2: CGPoint(x: 0.4899 * multiplier, y: 0.1934 * multiplier))
        path.addCurve(to: CGPoint(x: 0.4818 * multiplier, y: 0.2864 * multiplier), controlPoint1: CGPoint(x: 0.4862 * multiplier, y: 0.2672 * multiplier), controlPoint2: CGPoint(x: 0.4857 * multiplier, y: 0.2772 * multiplier))
        path.addCurve(to: CGPoint(x: 0.4046 * multiplier, y: 0.347 * multiplier), controlPoint1: CGPoint(x: 0.4667 * multiplier, y: 0.3221 * multiplier), controlPoint2: CGPoint(x: 0.4304 * multiplier, y: 0.3355 * multiplier))
        path.addCurve(to: CGPoint(x: 0.5614 * multiplier, y: 0.526 * multiplier), controlPoint1: CGPoint(x: 0.4008 * multiplier, y: 0.3487 * multiplier), controlPoint2: CGPoint(x: 0.5614 * multiplier, y: 0.526 * multiplier))
        path.addLine(to: CGPoint(x: 0.5972 * multiplier, y: 0.4973 * multiplier))
        path.addLine(to: CGPoint(x: 0.4641 * multiplier, y: 0.3555 * multiplier))
        path.addCurve(to: CGPoint(x: 0.5225 * multiplier, y: 0.2993 * multiplier), controlPoint1: CGPoint(x: 0.4641 * multiplier, y: 0.3555 * multiplier), controlPoint2: CGPoint(x: 0.5022 * multiplier, y: 0.3349 * multiplier))
        path.addCurve(to: CGPoint(x: 0.5287 * multiplier, y: 0.2182 * multiplier), controlPoint1: CGPoint(x: 0.5347 * multiplier, y: 0.2777 * multiplier), controlPoint2: CGPoint(x: 0.5396 * multiplier, y: 0.2495 * multiplier))
        path.addCurve(to: CGPoint(x: 0.4983 * multiplier, y: 0.177 * multiplier), controlPoint1: CGPoint(x: 0.5237 * multiplier, y: 0.2042 * multiplier), controlPoint2: CGPoint(x: 0.5152 * multiplier, y: 0.189 * multiplier))
        path.addCurve(to: CGPoint(x: 0.4379 * multiplier, y: 0.1527 * multiplier), controlPoint1: CGPoint(x: 0.4713 * multiplier, y: 0.1577 * multiplier), controlPoint2: CGPoint(x: 0.4445 * multiplier, y: 0.1538 * multiplier))
        path.addCurve(to: CGPoint(x: 0.363 * multiplier, y: 0.1499 * multiplier), controlPoint1: CGPoint(x: 0.4223 * multiplier, y: 0.1502 * multiplier), controlPoint2: CGPoint(x: 0.3907 * multiplier, y: 0.1497 * multiplier))
        path.move(to: CGPoint(x: 0.3126 * multiplier, y: 0.1894 * multiplier))
        path.addLine(to: CGPoint(x: 0.3132 * multiplier, y: 0.482 * multiplier))
        path.addCurve(to: CGPoint(x: 0.1263 * multiplier, y: 0.3218 * multiplier), controlPoint1: CGPoint(x: 0.3132 * multiplier, y: 0.482 * multiplier), controlPoint2: CGPoint(x: 0.1146 * multiplier, y: 0.4828 * multiplier))
        path.addCurve(to: CGPoint(x: 0.3126 * multiplier, y: 0.1894 * multiplier), controlPoint1: CGPoint(x: 0.1339 * multiplier, y: 0.2157 * multiplier), controlPoint2: CGPoint(x: 0.2598 * multiplier, y: 0.1892 * multiplier))

        return path
    }
}

extension UIBezierPath {
    static var unwrapLogo: UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0.534, y: 0.5816))
        path.addCurve(to: CGPoint(x: 0.1877, y: 0.088), controlPoint1: CGPoint(x: 0.534, y: 0.5816), controlPoint2: CGPoint(x: 0.2529, y: 0.4205))
        path.addCurve(to: CGPoint(x: 0.9728, y: 0.8259), controlPoint1: CGPoint(x: 0.4922, y: 0.4949), controlPoint2: CGPoint(x: 1.0968, y: 0.4148))
        path.addCurve(to: CGPoint(x: 0.0397, y: 0.5431), controlPoint1: CGPoint(x: 0.7118, y: 0.5248), controlPoint2: CGPoint(x: 0.3329, y: 0.7442))
        path.addCurve(to: CGPoint(x: 0.6211, y: 0.0279), controlPoint1: CGPoint(x: 0.508, y: 1.1956), controlPoint2: CGPoint(x: 1.3042, y: 0.5345))
        path.addCurve(to: CGPoint(x: 0.6904, y: 0.3615), controlPoint1: CGPoint(x: 0.7282, y: 0.2481), controlPoint2: CGPoint(x: 0.6904, y: 0.3615))
        return path
    }
}
