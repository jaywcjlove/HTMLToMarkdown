// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import JavaScriptCore

public enum HTMLToMarkdownError: Error, CustomStringConvertible {
    case resourceNotFound
    case jsContextInitializationFailed
    case prettierObjectNotFound
    case formattingFailed(String)
    
    public var description: String {
        switch self {
        case .resourceNotFound:
            return "html-to-markdown.bundle.min.js resource not found"
        case .jsContextInitializationFailed:
            return "Failed to initialize JavaScript context"
        case .prettierObjectNotFound:
            return "HTMLToMarkdown object not found in JavaScript context"
        case .formattingFailed(let message):
            return "Conversion failed: \(message)"
        }
    }
}

public class HTMLToMarkdown {
    private var jsContext: JSContext?
    
    public init() throws {
        try setupJSContext()
    }
    
    public func conversion(_ html: String, options: [String: Any] = [:]) throws -> String {
        guard let jsContext = jsContext else {
            throw HTMLToMarkdownError.jsContextInitializationFailed
        }
        // Use RunLoop instead of semaphore, more suitable for single-threaded environment
        var result: Result<String, Error>?
        var isCompleted = false
        // Check Prettier availability
        guard jsContext.objectForKeyedSubscript("HTMLToMarkdown")?.isUndefined == false else {
            throw HTMLToMarkdownError.prettierObjectNotFound
        }
        
        // Convert options to JSON string
        let optionsData = try JSONSerialization.data(withJSONObject: options, options: [])
        let optionsString = String(data: optionsData, encoding: .utf8) ?? "{}"
        
        // Execute formatting
        let formatScript = """
        (function(code, optionsStr) {
            // Clean up previous results
            this._htmlToMarkdownResult = undefined;
            this._htmlToMarkdownError = undefined;
            
            // Set up callback function
            this.notifySwift = function(resultValue, errorValue) {
                if (errorValue) {
                    this._htmlToMarkdownError = errorValue;
                } else {
                    this._htmlToMarkdownResult = resultValue;
                }
                this._swiftCallback && this._swiftCallback();
            };
            
            try {
                var options = {};
                if (optionsStr && optionsStr !== '{}') {
                    options = JSON.parse(optionsStr);
                }
                var formatResult = HTMLToMarkdown(code, options);
                notifySwift(formatResult, null);
            } catch(e) {
                notifySwift(null, e.message || e.toString());
            }
        })
        """
        
        let formatFunction = jsContext.evaluateScript(formatScript)
        // Set up Swift callback
        let swiftCallback: @convention(block) () -> Void = {
            let jsResult = jsContext.objectForKeyedSubscript("_htmlToMarkdownResult")
            let jsError = jsContext.objectForKeyedSubscript("_htmlToMarkdownError")
            
            if let errorValue = jsError, !errorValue.isUndefined, !errorValue.isNull {
                let errorMessage = errorValue.toString() ?? "Unknown formatting error"
                result = .failure(HTMLToMarkdownError.formattingFailed(errorMessage))
            } else if let resultValue = jsResult, !resultValue.isUndefined, !resultValue.isNull {
                let formattedCode = resultValue.toString() ?? ""
                result = .success(formattedCode)
            } else {
                result = .failure(HTMLToMarkdownError.formattingFailed("No result received"))
            }
            isCompleted = true
        }
        jsContext.setObject(swiftCallback, forKeyedSubscript: "_swiftCallback" as NSString)
        // Call formatting function with options
        formatFunction?.call(withArguments: [html, optionsString])
        // Use more efficient waiting method
        let startTime = CFAbsoluteTimeGetCurrent()
        let timeout: CFAbsoluteTime = 10.0
        while !isCompleted {
            if CFAbsoluteTimeGetCurrent() - startTime > timeout {
                throw HTMLToMarkdownError.formattingFailed("Formatting operation timed out")
            }
            RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.01))
        }
        guard let finalResult = result else {
            throw HTMLToMarkdownError.formattingFailed("No formatting result received")
        }
        return try finalResult.get()
    }
    
    // 便利方法，保持向后兼容性
    public func conversion(_ html: String) throws -> String {
        return try conversion(html, options: [:])
    }
    
    private func setupJSContext() throws {
        // Load html-to-markdown bundle
        guard let bundlePath = Bundle.module.url(forResource: "html-to-markdown.bundle.min", withExtension: "js"),
              let bundleContent = try? String(contentsOf: bundlePath) else {
            throw HTMLToMarkdownError.resourceNotFound
        }
        
        // Initialize JavaScript context
        jsContext = JSContext()
        // Set up error handling
        jsContext?.exceptionHandler = { context, exception in
            print("JavaScript error: \(exception?.description ?? "Unknown error")")
        }
        // Load and execute the Prettier bundle
        guard let context = jsContext else {
            throw HTMLToMarkdownError.jsContextInitializationFailed
        }
        // Execute the bundle - don't check return value as it may be undefined for valid bundles
        context.evaluateScript(bundleContent)
        
        // Find Prettier object using a more systematic approach
        let toMarkdownObj = findPrettierObject(in: context)
        guard toMarkdownObj != nil else {
            throw HTMLToMarkdownError.prettierObjectNotFound
        }
    }
    /// Find Prettier object in JavaScript context
    private func findPrettierObject(in context: JSContext) -> JSValue? {
        // Priority order for finding Prettier
        let searchPaths = [
            "HTMLToMarkdown",           // Direct global
            "this.HTMLToMarkdown",      // Global this
            "window.HTMLToMarkdown",    // Window object (if exists)
            "globalThis.HTMLToMarkdown" // Modern global reference
        ]
        
        for path in searchPaths {
            if let obj = context.evaluateScript(path), !obj.isUndefined && !obj.isNull {
                return obj
            }
        }
        return nil
    }
}
