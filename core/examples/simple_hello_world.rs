// Copyright 2018-2025 the Deno authors. MIT license.
//! A very simple hello world example that just uses basic Deno.core APIs
//! without any custom ops or complex serialization.

use deno_core::*;

fn main() {
  // Initialize a minimal runtime instance with no custom extensions
  let mut runtime = JsRuntime::new(RuntimeOptions::default());

  // Execute a simple JavaScript script that uses only built-in Deno.core APIs
  runtime
    .execute_script(
      "<simple_hello_world>",
      r#"
// Simple hello world using Deno.core.print()
Deno.core.print("Hello from Deno.core on nanvix!\n");

// Show some basic runtime info
Deno.core.print("Deno.core version info available: " + (typeof Deno.core.version !== 'undefined') + "\n");

// Test basic JavaScript execution
const message = "JavaScript is working!";
Deno.core.print(message + "\n");

// Simple math calculation
const result = 2 + 3;
Deno.core.print("2 + 3 = " + result + "\n");

Deno.core.print("Simple hello world completed successfully!\n");
"#,
    )
    .unwrap();
}