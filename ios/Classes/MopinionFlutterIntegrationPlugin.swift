import Flutter
import UIKit
import MopinionSDK

public class MopinionFlutterIntegrationPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    
    private let METHOD_CHANNEL_NAME = "MopinionFlutterBridge/native"    // flutter communication channel
    
    // statics for the Flutter message communication
    private weak static var controller : FlutterViewController?
    
    private var eventSink: FlutterEventSink? = nil
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "MopinionFlutterBridge/native", binaryMessenger: registrar.messenger())
        let instance = MopinionFlutterIntegrationPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        let eventChannel = FlutterEventChannel(name: "MopinionFlutterBridge/native/events", binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(instance)
    }
    
    private let invalidArgError = MopinionFlutterIntegrationPluginError(code:"invalidArgs", message: "Invalid arguments.")
        
    // MARK: singleton
    private override init() {}  // singleton
    
    static let shared = MopinionFlutterIntegrationPlugin()
    
    // MARK: Flutter method handler
    
    // Actual message handler. Call this for instance from your (Flutter)AppDelegate
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let controller = UIApplication.shared.delegate?.window??.rootViewController as? FlutterViewController else {
            MopinionFlutterIntegrationPlugin.controller = nil
            return
        }
                    switch call.method {
            case MopinionFlutterAction.INIT_WITH_DEPLOYMENT.rawValue :
                initializeSdk(call: call, result: result)
                break
            case MopinionFlutterAction.TRIGGER_EVENT.rawValue:
                triggerEvent(controller:controller, call: call, result: result)
                break
            case MopinionFlutterAction.ADD_META_DATA.rawValue:
                addMetaData(controller: controller, call: call, result: result)
                break
            case MopinionFlutterAction.REMOVE_META_DATA.rawValue:
                self.removeMetadataWithKey(controller: controller, call: call, result: result)
                break
            case MopinionFlutterAction.REMOVE_ALL_META_DATA.rawValue:
                removeAllMetadata()
                break
            default:
                break
            }
            }
    

    // MARK: implementation of the Flutter methods

    private func initializeSdk(call: FlutterMethodCall, result: FlutterResult) {
        guard let deploymentKey = (call.arguments as? Dictionary<String, AnyObject>)?[MopinionFlutterArgument.DEPLOYMENT_KEY.rawValue] as? String else {
            result(FlutterError(code: invalidArgError.code, message: "\(invalidArgError.message) \(MopinionFlutterArgument.DEPLOYMENT_KEY.rawValue)", details: "Expected deployment key as String"))
            return
        }
        guard let enableLogging = (call.arguments as? Dictionary<String, AnyObject>)?[MopinionFlutterArgument.LOG.rawValue] as? Bool else {
            result(FlutterError(code: invalidArgError.code, message: "\(invalidArgError.message) \(MopinionFlutterArgument.LOG.rawValue)", details: "Expected log to be bool (true or false)"))
            return
        }
        MopinionSDK.load(deploymentKey, enableLogging)
        result(nil)
    }

    private func triggerEvent(controller: FlutterViewController, call: FlutterMethodCall, result: FlutterResult) {
        guard let eventName = (call.arguments as? Dictionary<String, AnyObject>)?[MopinionFlutterArgument.FIRST_ARGUMENT.rawValue] as? String else {
            result(FlutterError(code: invalidArgError.code, message: "\(invalidArgError.message) \(MopinionFlutterArgument.DEPLOYMENT_KEY.rawValue)", details: "Expected event name as String"))
            return
        }
        MopinionSDK.event(controller, eventName, onCallbackEvent: { mopinionEvent,response in
            guard let eventSink = self.eventSink else { return }
            switch mopinionEvent {
            case .FORM_CLOSED:
                eventSink("form_closed")
            case .FORM_OPEN:
                eventSink("form_open")
            case .FORM_SENT:
                eventSink("form_sent")
            case .NO_FORM_WILL_OPEN:
                eventSink("form_will_open")
            @unknown default:
                break
            }
        }, onCallbackEventError: { mopinionEvent,response in
            if let error = response.getError() {
                print("FlutterPLugin -> Error in \(self): callback event error failure.")
            }
        })
        result(nil)
    }

    private func addMetaData(controller: FlutterViewController, call: FlutterMethodCall, result: FlutterResult) {
        guard let key = (call.arguments as? Dictionary<String, AnyObject>)?[MopinionFlutterArgument.KEY.rawValue] as? String else {
            result(FlutterError(code: invalidArgError.code, message: "\(invalidArgError.message) \(MopinionFlutterArgument.KEY.rawValue)", details: "Expected key value for map of metadata."))
            return
        }
        guard let value = (call.arguments as? Dictionary<String, AnyObject>)?[MopinionFlutterArgument.VALUE.rawValue] as? String else {
            result(FlutterError(code: invalidArgError.code, message: "\(invalidArgError.message) \(MopinionFlutterArgument.VALUE.rawValue)", details: "Expected value for map of metadata."))
            return
        }
        MopinionSDK.data(key, value)
    }

    private func removeMetadataWithKey(controller: FlutterViewController, call: FlutterMethodCall, result: FlutterResult) {
        guard let key = (call.arguments as? Dictionary<String, AnyObject>)?[MopinionFlutterArgument.KEY.rawValue] as? String else {
            result(FlutterError(code: invalidArgError.code, message: "\(invalidArgError.message) \(MopinionFlutterArgument.KEY.rawValue)", details: "Expected key value for map of metadata."))
            return
        }
        MopinionSDK.removeData(forKey: key)
    }

    private func removeAllMetadata() {
        MopinionSDK.removeData()
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }

    private struct MopinionFlutterIntegrationPluginError {
        let code : String
        let message : String
        
        init(code: String, message: String) {
            self.code = code        // short keywword like errornumber or alphanumeric classification
            self.message = message  // brief human readable description of the error classication
        }
    }
    
    private enum MopinionFlutterAction: String {
        case INIT_WITH_DEPLOYMENT = "init_sdk"
        case ADD_META_DATA = "add_meta_data"
        case REMOVE_META_DATA = "remove_meta_data"
        case REMOVE_ALL_META_DATA = "remove_all_meta_data"
        case TRIGGER_EVENT = "trigger_event"
    }

    private enum MopinionFlutterArgument: String {
        case DEPLOYMENT_KEY = "deployment_key"
        case FIRST_ARGUMENT = "argument1"
        case KEY = "key"
        case LOG = "log"
        case VALUE = "value"
    }
}
