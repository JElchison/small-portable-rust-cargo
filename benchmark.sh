#!/bin/bash

set -eufx -o pipefail


echo ========================= Setup =========================

mkdir /tmp/hello-c || true
cat << EOF > /tmp/hello-c/hello.c
#include <stdio.h>
int main() {
    printf("Hello, World!\n");
}
EOF

echo ========================= Environment =========================

uname -a
lsb_release -a
gcc -v
rustc --version
cargo --version

cat ~/.cargo/config

cat /tmp/hello-c/hello.c

echo ========================= Control Case: Native C on Linux =========================

echo ========================= 64-bit Dynamic =========================

pushd /tmp/hello-c

rm -v hello || true

gcc -o hello -Os -flto -Wl,--gc-sections -s hello.c
./hello
file hello
ldd hello
stat --printf="%s\n" hello

popd

echo ========================= 32-bit Dynamic =========================

pushd /tmp/hello-c

rm -v hello || true

gcc -o hello -m32 -Os -flto -Wl,--gc-sections -s hello.c
./hello
file hello
ldd hello
stat --printf="%s\n" hello

popd

echo ========================= 64-bit Static =========================

pushd /tmp/hello-c

rm -v hello || true

gcc -o hello -static -Os -flto -Wl,--gc-sections -s hello.c
./hello
file hello
ldd hello || true
stat --printf="%s\n" hello

popd

echo ========================= 32-bit Static =========================

pushd /tmp/hello-c

rm -v hello || true

gcc -o hello -static -m32 -Os -flto -Wl,--gc-sections -s hello.c
./hello
file hello
ldd hello || true
stat --printf="%s\n" hello

popd

echo ========================= Case 1: Rust on Linux =========================

echo ========================= 64-bit Dynamic =========================

xargo clean || true
xargo build --release --target=x86_64-unknown-linux-gnu
xargo clean || true

xargo build --release --target=x86_64-unknown-linux-gnu
strip target/x86_64-unknown-linux-gnu/release/hello_cargo
target/x86_64-unknown-linux-gnu/release/hello_cargo
file target/x86_64-unknown-linux-gnu/release/hello_cargo
ldd target/x86_64-unknown-linux-gnu/release/hello_cargo
stat --printf="%s\n" target/x86_64-unknown-linux-gnu/release/hello_cargo

echo ========================= 32-bit Dynamic =========================

xargo clean || true
xargo build --release --target=i686-unknown-linux-gnu
xargo clean || true

xargo build --release --target=i686-unknown-linux-gnu
strip target/i686-unknown-linux-gnu/release/hello_cargo
target/i686-unknown-linux-gnu/release/hello_cargo
file target/i686-unknown-linux-gnu/release/hello_cargo
ldd target/i686-unknown-linux-gnu/release/hello_cargo
stat --printf="%s\n" target/i686-unknown-linux-gnu/release/hello_cargo

echo ========================= 64-bit Static =========================

cargo clean || true
cargo build --release --target=x86_64-unknown-linux-musl
cargo clean || true

cargo build --release --target=x86_64-unknown-linux-musl
strip target/x86_64-unknown-linux-musl/release/hello_cargo
target/x86_64-unknown-linux-musl/release/hello_cargo
file target/x86_64-unknown-linux-musl/release/hello_cargo
ldd target/x86_64-unknown-linux-musl/release/hello_cargo || true
stat --printf="%s\n" target/x86_64-unknown-linux-musl/release/hello_cargo

echo ========================= 32-bit Static =========================

cargo clean || true
cargo build --release --target=i686-unknown-linux-musl
cargo clean || true

cargo build --release --target=i686-unknown-linux-musl
strip target/i686-unknown-linux-musl/release/hello_cargo
target/i686-unknown-linux-musl/release/hello_cargo
file target/i686-unknown-linux-musl/release/hello_cargo
ldd target/i686-unknown-linux-musl/release/hello_cargo || true
stat --printf="%s\n" target/i686-unknown-linux-musl/release/hello_cargo

echo ========================= Case 2: Cross-compile Rust for Windows on Linux =========================

echo ========================= 64-bit Static =========================

xargo clean || true
xargo build --release --target=x86_64-pc-windows-gnu
xargo clean || true

xargo build --release --target=x86_64-pc-windows-gnu
strip target/x86_64-pc-windows-gnu/release/hello_cargo.exe
wine target/x86_64-pc-windows-gnu/release/hello_cargo.exe
file target/x86_64-pc-windows-gnu/release/hello_cargo.exe
ldd target/x86_64-pc-windows-gnu/release/hello_cargo.exe || true
stat --printf="%s\n" target/x86_64-pc-windows-gnu/release/hello_cargo.exe

echo ========================= 32-bit Static =========================

cargo clean || true
cargo build --release --target=i686-unknown-linux-musl
cargo clean || true

xargo build --release --target=i686-pc-windows-gnu
strip target/i686-pc-windows-gnu/release/hello_cargo.exe
wine target/i686-pc-windows-gnu/release/hello_cargo.exe
file target/i686-pc-windows-gnu/release/hello_cargo.exe
ldd target/i686-pc-windows-gnu/release/hello_cargo.exe || true
stat --printf="%s\n" target/i686-pc-windows-gnu/release/hello_cargo.exe

echo ========================= Done =========================
