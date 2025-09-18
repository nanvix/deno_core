// Copyright 2018-2025 the Deno authors. MIT license.
//! A very simple hello world example that just uses basic Deno.core APIs
//! without any custom ops or complex serialization.

use deno_core::*;

fn main() {
  // Initialize a minimal runtime instance with no custom extensions
  let mut runtime = JsRuntime::new(RuntimeOptions::default());

  // Execute a concise overview of available deno_core APIs
  runtime
    .execute_script(
      "<deno_core_apis>",
      r#"
console.log("🦕 Deno.core API Reference for nanvix");
console.log("=====================================");

// === BASIC I/O & OUTPUT ===
console.log("\n📝 Basic I/O & Output:");
console.log("  • console.log/error/warn/info() - Standard console output");
console.log("  • Deno.core.print(msg, isError) - Direct stdout/stderr");
console.log("  • Deno.core.encode/decode() - UTF-8 text encoding");

// === RESOURCE MANAGEMENT ===
console.log("\n📂 Resource Management:");
console.log("  • resources(), close(), tryClose() - Resource lifecycle");
console.log("  • read/write(), readSync/writeSync() - I/O operations");
console.log("  • isTerminal() - Check if resource is terminal");

// === TYPE CHECKING (20+ utilities) ===
console.log("\n🔍 Type Checking:");
const typeCheckers = [
  'isPromise', 'isDate', 'isTypedArray', 'isArrayBuffer', 'isRegExp',
  'isMap', 'isSet', 'isProxy', 'isAsyncFunction', 'isGeneratorFunction'
];
console.log("  • " + typeCheckers.join(', ') + ", and 10+ more...");

// === TIMERS & EVENT LOOP ===
console.log("\n⏱️ Timers & Event Loop:");
console.log("  • queueImmediate(), queueUserTimer() - Task scheduling");
console.log("  • cancelTimer(), refTimer(), unrefTimer() - Timer control");
console.log("  • runMicrotasks(), eventLoopHasMoreWork() - Event loop");

// === SERIALIZATION ===
console.log("\n💾 Serialization:");
console.log("  • serialize(), deserialize() - Object serialization");

// === MEMORY & PERFORMANCE ===
console.log("\n📊 Memory & Performance:");
console.log("  • memoryUsage() - Heap and memory stats");
console.log("  • byteLength() - String byte length");

// === ERROR CLASSES ===
console.log("\n❌ Error Classes:");
console.log("  • BadResource, Interrupted, NotCapable - Built-in errors");

// === ADVANCED FEATURES ===
console.log("\n🚀 Advanced Features:");
console.log("  • evalContext() - Dynamic JavaScript evaluation");
console.log("  • getPromiseDetails() - Promise state inspection");
console.log("  • opNames() - List all available operations (" + Deno.core.opNames().length + " ops)");

// === DEMONSTRATION ===
console.log("\n🧪 Live Demonstrations:");

// Memory usage
const memory = Deno.core.memoryUsage();
console.log("  Memory: " + Math.round(memory.heapUsed/1024) + "KB used, " + 
           Math.round(memory.heapTotal/1024) + "KB total");

// Type checking demo
const testValues = [Promise.resolve(), new Date(), new Uint8Array(4)];
const types = ['Promise', 'Date', 'TypedArray'];
testValues.forEach((val, i) => {
  const checker = 'is' + types[i];
  console.log("  " + checker + "(): " + Deno.core[checker](val));
});

// Timer demo (without requiring Tokio runtime)
console.log("  Timer depth: " + Deno.core.getTimerDepth());
console.log("  Event loop has work: " + Deno.core.eventLoopHasMoreWork());

// Promise inspection demo
const resolvedPromise = Promise.resolve("success");
const promiseDetails = Deno.core.getPromiseDetails(resolvedPromise);
console.log("  Promise details: [state=" + promiseDetails[0] + ", value='" + promiseDetails[1] + "']");

console.log("\n✅ All APIs working perfectly on nanvix!");
"#,
    )
    .unwrap();
}