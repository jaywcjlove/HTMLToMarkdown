import { nodeResolve } from "@rollup/plugin-node-resolve";
import terser from '@rollup/plugin-terser';
import sizes from 'rollup-plugin-sizes';
import nodePolyfills from 'rollup-plugin-polyfill-node';
import commonjs from '@rollup/plugin-commonjs';

const polyfills = `
// Polyfills for JavaScript Core environment
var global = this;
if (typeof window === 'undefined') {
    this.window = this;
}
if (typeof document === 'undefined') {
    this.document = {
        createElement: function() { return {}; },
        createTextNode: function(text) { return { textContent: text }; },
        querySelector: function() { return null; },
        querySelectorAll: function() { return []; },
        addEventListener: function() {},
        removeEventListener: function() {}
    };
}
if (typeof navigator === 'undefined') {
    this.navigator = { userAgent: 'JavaScript Core' };
}
if (typeof location === 'undefined') {
    this.location = { href: '' };
}
`;

export default {
    input: "./main.js",
    output: {
        file: "../Sources/HTMLToMarkdown/Resources/html-to-markdown.bundle.min.js",
        name: "HTMLToMarkdown",
        format: "iife",
        inlineDynamicImports: true,
        banner: polyfills,
    },
    plugins: [
        nodeResolve({
            browser: true,
            preferBuiltins: false
        }),
        commonjs(),
        nodePolyfills({
            exclude: ['fs', 'path', 'crypto', 'stream'] // 排除 JavaScript Core 不需要的模块
        }),
        terser(),
        // terser({
        //     compress: {
        //         drop_console: true,
        //         drop_debugger: true,
        //         pure_funcs: ['console.log', 'console.info', 'console.debug', 'console.warn'],
        //         passes: 3
        //     },
        //     mangle: {
        //         toplevel: true
        //     }
        // }),
        sizes()
    ],
};
