import SpriteKit

/// SpriteKit 场景：渲染简单角色形象（火柴人/色块）
/// Phase 0 使用基础几何图形 + 元素颜色表示角色
final class CharacterSpriteScene: SKScene {

    private let character: Character

    init(character: Character, size: CGSize) {
        self.character = character
        super.init(size: size)
        scaleMode = .aspectFit
        backgroundColor = .clear
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        view.allowsTransparency = true
        backgroundColor = .clear
        removeAllChildren()
        buildCharacter()
    }

    // MARK: - Character Building

    private func buildCharacter() {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let scale = sizeScale

        switch character.appearance.bodyType {
        case .robot:
            drawRobot(at: center, scale: scale)
        case .dragon:
            drawDragon(at: center, scale: scale)
        case .animal:
            drawAnimal(at: center, scale: scale)
        case .humanoid:
            drawHumanoid(at: center, scale: scale)
        case .monster:
            drawMonster(at: center, scale: scale)
        case .elemental:
            drawElemental(at: center, scale: scale)
        case .vehicle:
            drawVehicle(at: center, scale: scale)
        }
    }

    // MARK: - Body Type Renderers

    /// 机器人：矩形身体 + 方形头部 + 天线
    private func drawRobot(at center: CGPoint, scale: CGFloat) {
        // 身体
        let body = SKShapeNode(rectOf: CGSize(width: 30 * scale, height: 36 * scale), cornerRadius: 4 * scale)
        body.position = CGPoint(x: center.x, y: center.y - 6 * scale)
        body.fillColor = primaryUIColor
        body.strokeColor = secondaryUIColor
        body.lineWidth = 1.5
        addChild(body)

        // 头部
        let head = SKShapeNode(rectOf: CGSize(width: 24 * scale, height: 22 * scale), cornerRadius: 3 * scale)
        head.position = CGPoint(x: center.x, y: center.y + 24 * scale)
        head.fillColor = primaryUIColor
        head.strokeColor = secondaryUIColor
        head.lineWidth = 1.5
        addChild(head)

        // 眼睛
        let eyeL = SKShapeNode(rectOf: CGSize(width: 5 * scale, height: 5 * scale))
        eyeL.position = CGPoint(x: center.x - 5 * scale, y: center.y + 26 * scale)
        eyeL.fillColor = elementGlowColor
        eyeL.strokeColor = .clear
        addChild(eyeL)

        let eyeR = SKShapeNode(rectOf: CGSize(width: 5 * scale, height: 5 * scale))
        eyeR.position = CGPoint(x: center.x + 5 * scale, y: center.y + 26 * scale)
        eyeR.fillColor = elementGlowColor
        eyeR.strokeColor = .clear
        addChild(eyeR)

        // 天线
        let antenna = SKShapeNode(rectOf: CGSize(width: 2 * scale, height: 10 * scale))
        antenna.position = CGPoint(x: center.x, y: center.y + 40 * scale)
        antenna.fillColor = secondaryUIColor
        antenna.strokeColor = .clear
        addChild(antenna)

        let antennaTip = SKShapeNode(circleOfRadius: 3 * scale)
        antennaTip.position = CGPoint(x: center.x, y: center.y + 46 * scale)
        antennaTip.fillColor = elementGlowColor
        antennaTip.strokeColor = .clear
        addChild(antennaTip)

        // 手臂
        drawLimb(from: CGPoint(x: center.x - 15 * scale, y: center.y),
                 to: CGPoint(x: center.x - 24 * scale, y: center.y - 14 * scale),
                 width: 3 * scale)
        drawLimb(from: CGPoint(x: center.x + 15 * scale, y: center.y),
                 to: CGPoint(x: center.x + 24 * scale, y: center.y - 14 * scale),
                 width: 3 * scale)

        // 腿
        drawLimb(from: CGPoint(x: center.x - 8 * scale, y: center.y - 24 * scale),
                 to: CGPoint(x: center.x - 10 * scale, y: center.y - 40 * scale),
                 width: 3 * scale)
        drawLimb(from: CGPoint(x: center.x + 8 * scale, y: center.y - 24 * scale),
                 to: CGPoint(x: center.x + 10 * scale, y: center.y - 40 * scale),
                 width: 3 * scale)
    }

    /// 龙：三角身体 + 翅膀轮廓
    private func drawDragon(at center: CGPoint, scale: CGFloat) {
        // 身体（椭圆）
        let body = SKShapeNode(ellipseOf: CGSize(width: 32 * scale, height: 40 * scale))
        body.position = CGPoint(x: center.x, y: center.y - 4 * scale)
        body.fillColor = primaryUIColor
        body.strokeColor = secondaryUIColor
        body.lineWidth = 1.5
        addChild(body)

        // 头部
        let head = SKShapeNode(circleOfRadius: 12 * scale)
        head.position = CGPoint(x: center.x, y: center.y + 28 * scale)
        head.fillColor = primaryUIColor
        head.strokeColor = secondaryUIColor
        head.lineWidth = 1.5
        addChild(head)

        // 眼睛
        let eye = SKShapeNode(circleOfRadius: 3 * scale)
        eye.position = CGPoint(x: center.x, y: center.y + 30 * scale)
        eye.fillColor = elementGlowColor
        eye.strokeColor = .clear
        addChild(eye)

        // 左翅膀
        let wingL = UIBezierPath()
        wingL.move(to: CGPoint(x: center.x - 14 * scale, y: center.y + 8 * scale))
        wingL.addLine(to: CGPoint(x: center.x - 38 * scale, y: center.y + 24 * scale))
        wingL.addLine(to: CGPoint(x: center.x - 28 * scale, y: center.y - 4 * scale))
        wingL.close()
        let wingLNode = SKShapeNode(path: wingL.cgPath)
        wingLNode.fillColor = primaryUIColor.withAlphaComponent(0.6)
        wingLNode.strokeColor = secondaryUIColor
        wingLNode.lineWidth = 1
        addChild(wingLNode)

        // 右翅膀
        let wingR = UIBezierPath()
        wingR.move(to: CGPoint(x: center.x + 14 * scale, y: center.y + 8 * scale))
        wingR.addLine(to: CGPoint(x: center.x + 38 * scale, y: center.y + 24 * scale))
        wingR.addLine(to: CGPoint(x: center.x + 28 * scale, y: center.y - 4 * scale))
        wingR.close()
        let wingRNode = SKShapeNode(path: wingR.cgPath)
        wingRNode.fillColor = primaryUIColor.withAlphaComponent(0.6)
        wingRNode.strokeColor = secondaryUIColor
        wingRNode.lineWidth = 1
        addChild(wingRNode)

        // 尾巴
        let tail = UIBezierPath()
        tail.move(to: CGPoint(x: center.x, y: center.y - 24 * scale))
        tail.addCurve(
            to: CGPoint(x: center.x + 18 * scale, y: center.y - 42 * scale),
            controlPoint1: CGPoint(x: center.x + 4 * scale, y: center.y - 30 * scale),
            controlPoint2: CGPoint(x: center.x + 14 * scale, y: center.y - 38 * scale)
        )
        let tailNode = SKShapeNode(path: tail.cgPath)
        tailNode.fillColor = .clear
        tailNode.strokeColor = primaryUIColor
        tailNode.lineWidth = 3 * scale
        addChild(tailNode)
    }

    /// 动物：圆形身体 + 耳朵
    private func drawAnimal(at center: CGPoint, scale: CGFloat) {
        // 身体
        let body = SKShapeNode(ellipseOf: CGSize(width: 34 * scale, height: 30 * scale))
        body.position = CGPoint(x: center.x, y: center.y - 10 * scale)
        body.fillColor = primaryUIColor
        body.strokeColor = secondaryUIColor
        body.lineWidth = 1.5
        addChild(body)

        // 头部
        let head = SKShapeNode(circleOfRadius: 14 * scale)
        head.position = CGPoint(x: center.x, y: center.y + 14 * scale)
        head.fillColor = primaryUIColor
        head.strokeColor = secondaryUIColor
        head.lineWidth = 1.5
        addChild(head)

        // 耳朵
        let earL = SKShapeNode(ellipseOf: CGSize(width: 8 * scale, height: 14 * scale))
        earL.position = CGPoint(x: center.x - 10 * scale, y: center.y + 30 * scale)
        earL.fillColor = primaryUIColor
        earL.strokeColor = secondaryUIColor
        earL.lineWidth = 1
        addChild(earL)

        let earR = SKShapeNode(ellipseOf: CGSize(width: 8 * scale, height: 14 * scale))
        earR.position = CGPoint(x: center.x + 10 * scale, y: center.y + 30 * scale)
        earR.fillColor = primaryUIColor
        earR.strokeColor = secondaryUIColor
        earR.lineWidth = 1
        addChild(earR)

        // 眼睛
        let eyeL = SKShapeNode(circleOfRadius: 3 * scale)
        eyeL.position = CGPoint(x: center.x - 5 * scale, y: center.y + 16 * scale)
        eyeL.fillColor = .white
        eyeL.strokeColor = secondaryUIColor
        addChild(eyeL)

        let eyeR = SKShapeNode(circleOfRadius: 3 * scale)
        eyeR.position = CGPoint(x: center.x + 5 * scale, y: center.y + 16 * scale)
        eyeR.fillColor = .white
        eyeR.strokeColor = secondaryUIColor
        addChild(eyeR)

        // 瞳孔
        let pupilL = SKShapeNode(circleOfRadius: 1.5 * scale)
        pupilL.position = CGPoint(x: center.x - 5 * scale, y: center.y + 16 * scale)
        pupilL.fillColor = .black
        pupilL.strokeColor = .clear
        addChild(pupilL)

        let pupilR = SKShapeNode(circleOfRadius: 1.5 * scale)
        pupilR.position = CGPoint(x: center.x + 5 * scale, y: center.y + 16 * scale)
        pupilR.fillColor = .black
        pupilR.strokeColor = .clear
        addChild(pupilR)

        // 腿
        drawLimb(from: CGPoint(x: center.x - 10 * scale, y: center.y - 24 * scale),
                 to: CGPoint(x: center.x - 12 * scale, y: center.y - 38 * scale),
                 width: 4 * scale)
        drawLimb(from: CGPoint(x: center.x + 10 * scale, y: center.y - 24 * scale),
                 to: CGPoint(x: center.x + 12 * scale, y: center.y - 38 * scale),
                 width: 4 * scale)
    }

    /// 人形：火柴人风格
    private func drawHumanoid(at center: CGPoint, scale: CGFloat) {
        // 头
        let head = SKShapeNode(circleOfRadius: 10 * scale)
        head.position = CGPoint(x: center.x, y: center.y + 28 * scale)
        head.fillColor = primaryUIColor
        head.strokeColor = secondaryUIColor
        head.lineWidth = 1.5
        addChild(head)

        // 眼睛
        let eyeL = SKShapeNode(circleOfRadius: 2 * scale)
        eyeL.position = CGPoint(x: center.x - 4 * scale, y: center.y + 30 * scale)
        eyeL.fillColor = .white
        eyeL.strokeColor = .clear
        addChild(eyeL)

        let eyeR = SKShapeNode(circleOfRadius: 2 * scale)
        eyeR.position = CGPoint(x: center.x + 4 * scale, y: center.y + 30 * scale)
        eyeR.fillColor = .white
        eyeR.strokeColor = .clear
        addChild(eyeR)

        // 身体（线条）
        drawLimb(from: CGPoint(x: center.x, y: center.y + 18 * scale),
                 to: CGPoint(x: center.x, y: center.y - 10 * scale),
                 width: 3 * scale)

        // 手臂
        drawLimb(from: CGPoint(x: center.x, y: center.y + 12 * scale),
                 to: CGPoint(x: center.x - 20 * scale, y: center.y - 2 * scale),
                 width: 2.5 * scale)
        drawLimb(from: CGPoint(x: center.x, y: center.y + 12 * scale),
                 to: CGPoint(x: center.x + 20 * scale, y: center.y - 2 * scale),
                 width: 2.5 * scale)

        // 腿
        drawLimb(from: CGPoint(x: center.x, y: center.y - 10 * scale),
                 to: CGPoint(x: center.x - 14 * scale, y: center.y - 36 * scale),
                 width: 2.5 * scale)
        drawLimb(from: CGPoint(x: center.x, y: center.y - 10 * scale),
                 to: CGPoint(x: center.x + 14 * scale, y: center.y - 36 * scale),
                 width: 2.5 * scale)
    }

    /// 怪兽：不规则色块
    private func drawMonster(at center: CGPoint, scale: CGFloat) {
        // 主体（大圆形色块）
        let body = SKShapeNode(circleOfRadius: 22 * scale)
        body.position = CGPoint(x: center.x, y: center.y - 2 * scale)
        body.fillColor = primaryUIColor
        body.strokeColor = secondaryUIColor
        body.lineWidth = 2
        addChild(body)

        // 角/突起
        let hornL = SKShapeNode(ellipseOf: CGSize(width: 6 * scale, height: 16 * scale))
        hornL.position = CGPoint(x: center.x - 12 * scale, y: center.y + 22 * scale)
        hornL.zRotation = .pi / 6
        hornL.fillColor = secondaryUIColor
        hornL.strokeColor = primaryUIColor
        hornL.lineWidth = 1
        addChild(hornL)

        let hornR = SKShapeNode(ellipseOf: CGSize(width: 6 * scale, height: 16 * scale))
        hornR.position = CGPoint(x: center.x + 12 * scale, y: center.y + 22 * scale)
        hornR.zRotation = -.pi / 6
        hornR.fillColor = secondaryUIColor
        hornR.strokeColor = primaryUIColor
        hornR.lineWidth = 1
        addChild(hornR)

        // 大眼睛
        let eyeL = SKShapeNode(circleOfRadius: 5 * scale)
        eyeL.position = CGPoint(x: center.x - 7 * scale, y: center.y + 4 * scale)
        eyeL.fillColor = .white
        eyeL.strokeColor = secondaryUIColor
        addChild(eyeL)

        let eyeR = SKShapeNode(circleOfRadius: 5 * scale)
        eyeR.position = CGPoint(x: center.x + 7 * scale, y: center.y + 4 * scale)
        eyeR.fillColor = .white
        eyeR.strokeColor = secondaryUIColor
        addChild(eyeR)

        // 瞳孔
        let pupilL = SKShapeNode(circleOfRadius: 2.5 * scale)
        pupilL.position = CGPoint(x: center.x - 7 * scale, y: center.y + 4 * scale)
        pupilL.fillColor = .black
        pupilL.strokeColor = .clear
        addChild(pupilL)

        let pupilR = SKShapeNode(circleOfRadius: 2.5 * scale)
        pupilR.position = CGPoint(x: center.x + 7 * scale, y: center.y + 4 * scale)
        pupilR.fillColor = .black
        pupilR.strokeColor = .clear
        addChild(pupilR)

        // 嘴
        let mouth = UIBezierPath()
        mouth.move(to: CGPoint(x: center.x - 8 * scale, y: center.y - 8 * scale))
        mouth.addQuadCurve(
            to: CGPoint(x: center.x + 8 * scale, y: center.y - 8 * scale),
            controlPoint: CGPoint(x: center.x, y: center.y - 16 * scale)
        )
        let mouthNode = SKShapeNode(path: mouth.cgPath)
        mouthNode.fillColor = .clear
        mouthNode.strokeColor = secondaryUIColor
        mouthNode.lineWidth = 2
        addChild(mouthNode)

        // 短腿
        drawLimb(from: CGPoint(x: center.x - 10 * scale, y: center.y - 22 * scale),
                 to: CGPoint(x: center.x - 12 * scale, y: center.y - 34 * scale),
                 width: 5 * scale)
        drawLimb(from: CGPoint(x: center.x + 10 * scale, y: center.y - 22 * scale),
                 to: CGPoint(x: center.x + 12 * scale, y: center.y - 34 * scale),
                 width: 5 * scale)
    }

    /// 元素体：发光的圆形
    private func drawElemental(at center: CGPoint, scale: CGFloat) {
        // 外发光
        let glow = SKShapeNode(circleOfRadius: 26 * scale)
        glow.position = center
        glow.fillColor = elementGlowColor.withAlphaComponent(0.2)
        glow.strokeColor = .clear
        addChild(glow)

        // 主体
        let body = SKShapeNode(circleOfRadius: 18 * scale)
        body.position = center
        body.fillColor = primaryUIColor
        body.strokeColor = elementGlowColor
        body.lineWidth = 2
        body.glowWidth = 4
        addChild(body)

        // 内核
        let core = SKShapeNode(circleOfRadius: 6 * scale)
        core.position = center
        core.fillColor = .white
        core.strokeColor = .clear
        addChild(core)
    }

    /// 载具：矩形 + 轮子
    private func drawVehicle(at center: CGPoint, scale: CGFloat) {
        // 车身
        let body = SKShapeNode(rectOf: CGSize(width: 40 * scale, height: 20 * scale), cornerRadius: 6 * scale)
        body.position = CGPoint(x: center.x, y: center.y + 4 * scale)
        body.fillColor = primaryUIColor
        body.strokeColor = secondaryUIColor
        body.lineWidth = 1.5
        addChild(body)

        // 顶部
        let top = SKShapeNode(rectOf: CGSize(width: 24 * scale, height: 14 * scale), cornerRadius: 4 * scale)
        top.position = CGPoint(x: center.x, y: center.y + 18 * scale)
        top.fillColor = primaryUIColor.withAlphaComponent(0.7)
        top.strokeColor = secondaryUIColor
        top.lineWidth = 1
        addChild(top)

        // 轮子
        let wheelL = SKShapeNode(circleOfRadius: 6 * scale)
        wheelL.position = CGPoint(x: center.x - 12 * scale, y: center.y - 10 * scale)
        wheelL.fillColor = secondaryUIColor
        wheelL.strokeColor = .gray
        wheelL.lineWidth = 1
        addChild(wheelL)

        let wheelR = SKShapeNode(circleOfRadius: 6 * scale)
        wheelR.position = CGPoint(x: center.x + 12 * scale, y: center.y - 10 * scale)
        wheelR.fillColor = secondaryUIColor
        wheelR.strokeColor = .gray
        wheelR.lineWidth = 1
        addChild(wheelR)

        // 灯（元素色）
        let light = SKShapeNode(circleOfRadius: 3 * scale)
        light.position = CGPoint(x: center.x + 18 * scale, y: center.y + 6 * scale)
        light.fillColor = elementGlowColor
        light.strokeColor = .clear
        addChild(light)
    }

    // MARK: - Helpers

    private func drawLimb(from start: CGPoint, to end: CGPoint, width: CGFloat) {
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)
        let node = SKShapeNode(path: path.cgPath)
        node.strokeColor = primaryUIColor
        node.lineWidth = width
        node.lineCap = .round
        addChild(node)
    }

    private var sizeScale: CGFloat {
        let baseScale = min(size.width, size.height) / 120.0
        switch character.appearance.size {
        case .small:  return baseScale * 0.8
        case .medium: return baseScale * 1.0
        case .large:  return baseScale * 1.15
        case .giant:  return baseScale * 1.3
        }
    }

    private var primaryUIColor: UIColor {
        UIColor(hex: character.appearance.primaryColor) ?? .systemGray
    }

    private var secondaryUIColor: UIColor {
        UIColor(hex: character.appearance.secondaryColor) ?? .darkGray
    }

    private var elementGlowColor: UIColor {
        switch character.element {
        case .fire:      return .systemOrange
        case .water:     return .systemCyan
        case .wind:      return .systemGreen
        case .earth:     return .systemBrown
        case .lightning: return .systemYellow
        case .ice:       return .cyan
        case .shadow:    return .systemPurple
        case .light:     return .systemYellow
        case .normal:    return .lightGray
        }
    }
}

// MARK: - UIColor hex init

private extension UIColor {
    convenience init?(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexString.hasPrefix("#") { hexString.removeFirst() }
        guard hexString.count == 6,
              let value = UInt64(hexString, radix: 16) else { return nil }
        let r = CGFloat((value >> 16) & 0xFF) / 255.0
        let g = CGFloat((value >> 8) & 0xFF) / 255.0
        let b = CGFloat(value & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
