// Copyright 2018-2025 the Deno authors. MIT license.
//! Hackathon demo: Reading JavaScript code from an external file using Rust std
//! and executing it in deno_core runtime. This demonstrates the integration
//! between Rust file I/O and JavaScript execution on nanvix.

use deno_core::*;
use std::fs;

fn main() {
  println!("🚀 Hackathon Demo: External JavaScript Execution");
  println!("================================================");

  // Define the path to the JavaScript file
  let js_file_path = "/home/danbugs/repos/nanvix/js-code-samples/index.js";
  
  // Read the JavaScript file using Rust std
  println!("📂 Reading JavaScript from: {}", js_file_path);
  
  let js_content = match fs::read_to_string(js_file_path) {
    Ok(content) => {
      println!("✅ Successfully read {} bytes", content.len());
      content
    },
    Err(e) => {
      eprintln!("❌ Failed to read file: {}", e);
      eprintln!("💡 Make sure the file exists and is readable");
      return;
    }
  };

  // Initialize deno_core runtime
  println!("\n🦕 Initializing deno_core runtime...");
  let mut runtime = JsRuntime::new(RuntimeOptions::default());

  // Execute the JavaScript code read from file
  println!("⚡ Executing JavaScript code...");
  println!("--- JavaScript Output ---");
  
  match runtime.execute_script("<external_js>", js_content) {
    Ok(_) => {
      println!("--- End JavaScript Output ---");
      println!("✅ JavaScript execution completed successfully!");
    },
    Err(e) => {
      println!("--- End JavaScript Output ---");
      eprintln!("❌ JavaScript execution failed: {}", e);
      return;
    }
  }

  println!("\n🏁 Hackathon demo completed!");
}