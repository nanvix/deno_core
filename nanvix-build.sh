#!/bin/bash

# nanvix-build.sh
# Build script for deno_core on Nanvix operating system

set -euo pipefail

echo "=== Deno Core Build for Nanvix ==="
echo ""

# Step 1: Set up Cargo configuration
echo ""
echo "Step 1: Setting up Cargo configuration..."
mkdir -p .cargo
cat > .cargo/config.toml << 'EOF'
[patch.crates-io]
libc = { git = "https://github.com/nanvix/libc", rev = "87fbecbfbe5d870f007dbf77dd46c17197b29384" }
libloading = { git = "https://github.com/nanvix/rust_libloading", branch = "nanvix/v0.8.8" }
errno = { git = "https://github.com/nanvix/rust-errno", branch = "nanvix/v0.3.13" }
fslock = { git = "https://github.com/nanvix/fslock", branch = "nanvix/v0.2.1" }
clang-sys = { git = "https://github.com/nanvix/clang-sys", rev = "ee92b8a58fa3031b4fd34bf2e15906f016984263" }
EOF

# Step 2: Set up environment
echo ""
echo "Step 2: Setting up build environment..."
export NANVIX_HOME=${NANVIX_HOME:-$HOME/repos/nanvix}
export NANVIX_TOOLCHAIN=${NANVIX_TOOLCHAIN:-$HOME/repos/nanvix-toolchain-v09x-copy/}
export TARGET="i686-unknown-nanvix"
export CARGO_CFG_TARGET_ARCH="x86"
export CARGO_CFG_TARGET_OS="nanvix"

# Step 3: Configure GN arguments with SSE disabled
echo ""
echo "Step 3: Configuring GN arguments..."
export GN_VERBOSE=1
export PRINT_GN_ARGS=yes

# Enable ICU but in a minimal way for deno_core
export EXTRA_GN_ARGS="
target_os=\"nanvix\"
target_cpu=\"x86\"
v8_target_cpu=\"x86\"
is_clang=true
use_custom_libcxx=false
v8_enable_pointer_compression=false
v8_enable_webassembly=false
v8_enable_i18n_support=true
icu_use_data_file=false
v8_use_external_startup_data=false
treat_warnings_as_errors=false
is_debug=false
extra_cflags=\"-m32 -march=i686\"
extra_cxxflags=\"-m32 -march=i686 \"
extra_ldflags=\"-m32\"
"

# Step 4: Set up bindgen to find C++ headers
echo ""
echo "Step 4: Setting up bindgen for C++ headers..."
export BINDGEN_EXTRA_CLANG_ARGS="\
--target=i686-unknown-nanvix \
--sysroot=$NANVIX_TOOLCHAIN/i686-nanvix \
-I$NANVIX_TOOLCHAIN/include/c++/v1 \
-I$NANVIX_TOOLCHAIN/include/i686-unknown-nanvix/c++/v1 \
-I$NANVIX_TOOLCHAIN/lib/clang/21/include \
-I$NANVIX_TOOLCHAIN/i686-nanvix/include \
-m32 \
-D__nanvix__ \
-D_GNU_SOURCE=1 \
-DV8_OS_NANVIX"

# Step 5: Create minimal stubs
echo ""
echo "Step 5: Creating runtime stubs..."
STUBS_FILE="/tmp/nanvix_deno_core_stubs.c"
cat > $STUBS_FILE << 'EOF'
#include <stddef.h>

// DSO handle stub
void* __dso_handle = 0;

// Thread-local destructor stub
int __cxa_thread_atexit_impl(void (*func)(void*), void* arg, void* dso_handle) {
    return 0;
}

// C++ exception handling stubs
struct __cxa_eh_globals {
    void* caughtExceptions;
    unsigned int uncaughtExceptions;
};

static struct __cxa_eh_globals eh_globals = { NULL, 0 };

struct __cxa_eh_globals* __cxa_get_globals(void) {
    return &eh_globals;
}

struct __cxa_eh_globals* __cxa_get_globals_fast(void) {
    return &eh_globals;
}

// Guard variables for static initialization
int __cxa_guard_acquire(long long* guard) {
    if (*guard == 0) {
        *guard = 1;
        return 1;
    }
    return 0;
}

void __cxa_guard_release(long long* guard) {
    *guard = 1;
}

void __cxa_guard_abort(long long* guard) {
    *guard = 0;
}
EOF

$NANVIX_TOOLCHAIN/bin/clang -c $STUBS_FILE -o /tmp/nanvix_deno_core_stubs.o \
    -target i686-elf -m32 -I$NANVIX_TOOLCHAIN/i686-nanvix/include

# Step 6: Build with V8 from source
echo ""
echo "Step 6: Building deno_core with V8 from source..."
echo "This will build V8 from source with the GN configuration..."

V8_FROM_SOURCE=1 \
RUSTFLAGS="\
-C target-cpu=i686 \
-C relocation-model=static \
-C link-arg=/tmp/nanvix_deno_core_stubs.o \
-C link-arg=-T$NANVIX_HOME/build/user/linker/x86/user.ld \
-C link-arg=-L$NANVIX_TOOLCHAIN/lib/i686-unknown-nanvix/ \
-C link-arg=-lc++ \
-C link-arg=-lc++abi \
-C link-arg=-L$NANVIX_TOOLCHAIN/i686-nanvix/lib/ \
-C link-arg=-lc \
-C link-arg=-lm \
-C link-arg=-L$NANVIX_TOOLCHAIN/lib/clang/21/lib/i386-unknown-nanvix/ \
-C link-arg=-lclang_rt.builtins" \
cargo +nanvix-x86-nightly build --target i686-unknown-nanvix -vv 2>&1 | tee output-deno-core.txt

echo ""
echo "Build complete!"

# Step 7: Build and run hello_world example
echo ""
echo "Step 7: Building hello_world example..."

V8_FROM_SOURCE=1 \
RUSTFLAGS="\
-C target-cpu=i686 \
-C relocation-model=static \
-C link-arg=/tmp/nanvix_deno_core_stubs.o \
-C link-arg=-T$NANVIX_HOME/build/user/linker/x86/user.ld \
-C link-arg=-L$NANVIX_TOOLCHAIN/lib/i686-unknown-nanvix/ \
-C link-arg=-lc++ \
-C link-arg=-lc++abi \
-C link-arg=-L$NANVIX_TOOLCHAIN/i686-nanvix/lib/ \
-C link-arg=-lc \
-C link-arg=-lm \
-C link-arg=-L$NANVIX_TOOLCHAIN/lib/clang/21/lib/i386-unknown-nanvix/ \
-C link-arg=-lclang_rt.builtins" \
cargo +nanvix-x86-nightly build --target i686-unknown-nanvix --example hello_world -vv 2>&1 | tee output-hello-world.txt

echo ""
echo "Hello world example build complete!"
