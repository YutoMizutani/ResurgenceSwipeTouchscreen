//
//  SCNNode+.swift
//  SwipeProgram
//
//  Created by Yuto Mizutani on 2018/12/09.
//  Copyright © 2018 Yuto Mizutani. All rights reserved.
//

import SceneKit

extension SCNNode {
    func rotate(by angle: Float, around axis: SCNVector3) {
        let transform = SCNMatrix4MakeRotation(angle, axis.x, axis.y, axis.z)
        self.transform = SCNMatrix4Mult(self.transform, transform)
    }

    func rotateUp(by angle: Float) {
        let axis = SCNVector3(1, 0, 0)
        rotate(by: angle, around: axis)
    }

    func rotateRight(by angle: Float) {
        let axis = SCNVector3(0, 1, 0)
        rotate(by: angle, around: axis)
    }

    func rotateZ(by angle: Float) {
        let axis = SCNVector3(0, 0, 1)
        rotate(by: angle, around: axis)
    }
}
