import Flutter
import UIKit
import KlarnaMobileSDK
import AuthenticationServices


public class KlarnaSignInFlutterPlugin: NSObject, FlutterPlugin, FlutterStreamHandler, KlarnaEventHandler, ASWebAuthenticationPresentationContextProviding {

    private var eventSink: FlutterEventSink?
    private var sdk: KlarnaSignInSDK?

    private var returnUrl: URL?
    private var environment: KlarnaEnvironment = .playground
    private var region: KlarnaRegion = .na
    private var theme: KlarnaTheme = .light

    public static func register(with registrar: FlutterPluginRegistrar) {
        let method = FlutterMethodChannel(name: "klarna_signin/methods", binaryMessenger: registrar.messenger())
        let events = FlutterEventChannel(name: "klarna_signin/events", binaryMessenger: registrar.messenger())

        let instance = KlarnaSignInFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: method)
        events.setStreamHandler(instance)
    }

    // FlutterStreamHandler
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }

    // Flutter Method Calls
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            guard let args = call.arguments as? [String: Any], let returnUrlStr = args["returnUrl"] as? String, let url = URL(string: returnUrlStr) else {
                result(FlutterError(code: "ARG_ERROR", message: "returnUrl missing", details: nil))
                return
            }
            returnUrl = url

            if let env = (args["environment"] as? String)?.lowercased() {
                environment = env == "production" ? .production : .playground
            }
            if let reg = (args["region"] as? String)?.uppercased() {
                switch reg { case "NA": region = .na; case "OC": region = .oc; default: region = .eu }
            }
            if let th = (args["theme"] as? String)?.lowercased() {
                switch th { case "light": theme = .light; case "dark": theme = .dark; default: theme = .automatic }
            }

            sdk = KlarnaSignInSDK(theme: theme, environment: environment, region: region, returnUrl: url, eventHandler: self)
            result(nil)

        case "signIn":
            guard let args = call.arguments as? [String: Any],
                  let clientId = args["clientId"] as? String,
                  let scope = args["scope"] as? String,
                  let market = args["market"] as? String else {
                result(FlutterError(code: "ARG_ERROR", message: "missing signIn args", details: nil))
                return
            }
            let locale = args["locale"] as? String

            guard let s = sdk else {
                result(FlutterError(code: "NOT_INITIALIZED", message: "Call initialize() first", details: nil))
                return
            }

            s.signIn(
                clientId: clientId,
                scope: scope,
                market: market,
                locale: locale,
                presentationContext: self
            )
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
         
    }

    // 递归序列化
    private func serializeParam(_ value: Any) -> Any {
        if let token = value as? KlarnaSignInToken {
            return [
                "idToken": token.idToken ?? "",
                "accessToken": token.accessToken ?? "",
                "refreshToken": token.refreshToken ?? "",
                "scope": token.scope ?? "",
                "tokenType": token.tokenType ?? "",
                "expiresIn": token.expiresIn ?? 0
            ]
        } else if let dict = value as? [String: Any] {
            var serialized: [String: Any] = [:]
            for (k, v) in dict {
                serialized[k] = serializeParam(v)
            }
            return serialized
        } else if let array = value as? [Any] {
            return array.map { serializeParam($0) }
        } else {
            return value
        }
    }
    // KlarnaEventHandler
    public func klarnaComponent(_ klarnaComponent: KlarnaComponent, dispatchedEvent event: KlarnaProductEvent) {
        
    let map: [String: Any] = [
        "action": event.action,
        "params": serializeParam(event.params)
    ]
            // 确保在主线程回调 Flutter
    DispatchQueue.main.async {
        self.eventSink?(map)
    }
        
    }
    public func klarnaComponent(_ klarnaComponent: KlarnaComponent, encounteredError error: KlarnaError) {
        
        var map: [String: Any] = ["action": "ERROR"]
        map["params"] = ["message": error.localizedDescription]
            // 确保在主线程回调 Flutter
    DispatchQueue.main.async {
        self.eventSink?(map)
    }
        
    }
    // ASWebAuthenticationPresentationContextProviding
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        if Thread.isMainThread {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let key = windowScene.windows.first(where: { $0.isKeyWindow }) {
                return key
            } else {
                return UIApplication.shared.windows.first ?? UIWindow()
            }
        } else {
            var anchor: ASPresentationAnchor? = nil
            DispatchQueue.main.sync {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let key = windowScene.windows.first(where: { $0.isKeyWindow }) {
                    anchor = key
                } else {
                    anchor = UIApplication.shared.windows.first
                }
            }
            return anchor ?? UIWindow()
        }
    }
}
