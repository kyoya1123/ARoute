import SceneKit

extension SCNNode {
    class func sphereNode(color: UIColor) -> SCNNode {
        let geometry = SCNSphere(radius: 0.01)
        geometry.materials.first?.diffuse.contents = color
        return SCNNode(geometry: geometry)
    }
    
    class func textNode(text: String) -> SCNNode {
        let geometry = SCNText(string: text, extrusionDepth: 0.01)
        geometry.alignmentMode = CATextLayerAlignmentMode.center.rawValue
        if let material = geometry.firstMaterial {
            material.diffuse.contents = UIColor.white
            material.isDoubleSided = true
        }
        let textNode = SCNNode(geometry: geometry)
        geometry.font = UIFont.systemFont(ofSize: 0.5)
        textNode.scale = SCNVector3Make(0.02, 0.02, 0.02)
        let (min, max) = geometry.boundingBox
        textNode.pivot = SCNMatrix4MakeTranslation((max.x - min.x) / 2, min.y - 0.5, 0)
        let node = SCNNode()
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        node.constraints = [billboardConstraint]
        node.addChildNode(textNode)
        return node
    }
}
