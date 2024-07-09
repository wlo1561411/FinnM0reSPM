import UIKit

public class HighlightGesture: UIGestureRecognizer {
    public typealias OnHighlight = (_ isHighlight: Bool) -> Void

    private var onHighlight: OnHighlight?
    private var onClick: (() -> Void)?

    private var touchBeganPoint: CGPoint?

    // Will delay highlight for 0.1 second
    private var delayHighlightWorkItem: DispatchWorkItem?

    private(set) var isHighlight = false

    fileprivate func setupGestureClosure(onHighlight: OnHighlight? = nil, onClick: (() -> Void)? = nil) {
        self.onHighlight = onHighlight
        self.onClick = onClick
    }

    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        if let touch = touches.first, let vTmp = view {
            let superview = getOutermostSuperview(of: vTmp)
            let point = touch.location(in: superview)
            touchBeganPoint = point
        }

        cancelDelayHighlightWorkItem()

        let item = DispatchWorkItem(block: { [weak self] in
            guard let self else { return }
            self.cancelDelayHighlightWorkItem()

            self.isHighlight = true
            self.changeToHighlight()
        })

        delayHighlightWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: item)
    }

    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)

        if delayHighlightWorkItem != nil {
            performClickEvent()
            return
        }

        if isHighlight == false {
            return
        }

        performClickEvent()
    }

    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        cancelHighlight()
    }

    override public func canBePrevented(by preventingGestureRecognizer: UIGestureRecognizer) -> Bool {
        cancelHighlight()
        return super.canBePrevented(by: preventingGestureRecognizer)
    }

    override public func touchesMoved(_ touches: Set<UITouch>, with _: UIEvent?) {
        guard let vTmp = view, let touchPoint = touches.first?.location(in: vTmp) else {
            return
        }

        if delayHighlightWorkItem == nil, isHighlight == false {
            return
        }

        if
            touchPoint.x < -10 || touchPoint.y < -10 || touchPoint.x > vTmp.bounds.width + 10 || touchPoint.y > vTmp.bounds
                .height + 10
        {
            forceCancelGesture()
        }
        else { }
    }

    deinit {
        onHighlight = nil
        onClick = nil
    }
}

extension HighlightGesture {
    private func changeToHighlight() {
        guard isTouchWithinCurrentFrame() else { return }
        onHighlight?(true)
    }

    fileprivate func cancelHighlight() {
        cancelDelayHighlightWorkItem()
        isHighlight = false
        onHighlight?(false)
    }

    private func performClickEvent() {
        cancelDelayHighlightWorkItem()
        isHighlight = false
        onHighlight?(false)

        if isTouchWithinCurrentFrame() {
            onClick?()
            forceCancelGesture()
        }
        touchBeganPoint = nil
    }

    private func forceCancelGesture() {
        isEnabled = false
        isEnabled = true
    }

    private func getOutermostSuperview(of view: UIView) -> UIView {
        if let parentView = view.superview {
            return getOutermostSuperview(of: parentView)
        }
        return view
    }

    private func isTouchWithinCurrentFrame() -> Bool {
        guard let beganPoint = touchBeganPoint, let vTmp = view else { return false }

        let superview = getOutermostSuperview(of: vTmp)
        let endFrame = vTmp.convert(vTmp.bounds, to: superview)

        return endFrame.contains(beganPoint)
    }

    private func cancelDelayHighlightWorkItem() {
        delayHighlightWorkItem?.cancel()
        delayHighlightWorkItem = nil
    }
}

extension UIView {
    public func addHighlightGesture(onHighlight: HighlightGesture.OnHighlight? = nil, onClick: (() -> Void)? = nil) {
        if onHighlight == nil, onClick == nil {
            return
        }

        isUserInteractionEnabled = true
        let gesture = HighlightGesture()
        gesture.setupGestureClosure(onHighlight: onHighlight, onClick: onClick)
        addGestureRecognizer(gesture)
    }

    public func triggerNonHighlightEvent() {
        guard let oldGesture = gestureRecognizers?.first(where: { $0 is HighlightGesture }) as? HighlightGesture
        else { return }

        oldGesture.cancelHighlight()
    }
}
