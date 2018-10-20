# small-portable-rust-cargo
Cargo template project predefined with settings to build a Rust binary that compares to the size and portability of equivalent code written in C


## Summary of Methods

| **Case** | Control Case: Native C on Linux | Case 1: Rust on Linux | Case 2: Cross-compile Rust for Windows on Linux | Case 3: Rust on Windows via GNU | Case 4: Rust on Windows via MSVC | Control Case: Native C on Windows |
| ----------------------------- | ----------------- | ------------------------ | -------------------- | ------------------------- | ------------------------- | -------------------- |
| **Language**                  | C                 | Rust                     | Rust                 | Rust                      | Rust                      | C                    |
| **Built on**                  | Linux             | Linux                    | Linux                | Windows                   | Windows                   | Windows              |
| **Runs on**                   | Linux             | Linux                    | Windows              | Windows                   | Windows                   | Windows              |
| **Compiled**                  | Native            | Native                   | Cross-compiled       | Native                    | Native                    | Native               |
| **Dynamic Method**            | gcc               | xargo + strip            | N/A                  | RUSTFLAGS + cargo + strip | RUSTFLAGS + cargo + strip | MSVC                 |
| **Dynamic Target**            | $ARCH-linux-gnu   | $ARCH-unknown-linux-gnu  | N/A                  | $ARCH-pc-windows-gnu      | $ARCH-pc-windows-msvc     | N/A                  |
| **64-bit dynamic size**       |             6,112 |                   55,440 | N/A                  | ???                       | ???                       | ???                  |
| **32-bit dynamic size**       |             5,460 |                   50,672 | N/A                  | ???                       | ???                       | ???                  |
| **Dynamic target depends on** | Various .so files | Various .so files        | N/A                  | msvcrt.dll                | msvcr*.dll, ucrtbase.dll, vcruntime*.dll ??? | msvcr*.dll, ucrtbase.dll, vcruntime*.dll |
| **Static Method**             | gcc -static       | cargo + strip            | xargo + strip        | RUSTFLAGS + cargo + strip | RUSTFLAGS + cargo + strip | MSVC                 |
| **Static Target**             | $ARCH-linux-gnu   | $ARCH-unknown-linux-musl | $ARCH-pc-windows-gnu | $ARCH-pc-windows-gnu      | $ARCH-pc-windows-msvc     | N/A                  |
| **64-bit static size**        |           753,560 |                  513,816 |               82,944 | ???                       | ???                       | ???                  |
| **32-bit static size**        |           575,456 |                  513,180 |               59,406 | ???                       | ???                       | ???                  |

Notes:

* For the above tests, `$ARCH` is either `x86_64` or `i686`
* `msvcrt.dll` has been present on Windows OS editions since Windows 95 OSR2
* Entries above with `???` have not been attempted yet.  Feel free to submit a pull request with this data.


## How It Works

Supporting documentation is linked below, but here are the tidbits that accomplish a small, portable Rust binary:

* Compile with cargo's `--release` flag
* Strip the binary using `strip` from `binutils`
* Use nightly toolchain channel
    * See specific contents of `Cargo.toml` for optimizations that take advantage of this
* Use `musl` for a lighter-weight libc, when possible
* Use `xargo` to rebuild `std` and `core` with optimizations, when possible
    * See specific contents of `Xargo.toml`
* Use the system allocator instead of `jemalloc`

For explanations, please see linked documentation below.


## Getting Started

Use rustup to install your toolchain.  Follow the instructions at https://rustup.rs/:

```
$ curl https://sh.rustup.rs -sSf | sh
```

Configure the nightly channel as default:

```
$ rustup install nightly
```

The nightly channel is required for some of the optimizations used by this template project.

Install other dependencies as needed for your configuration, such as [xargo](https://github.com/japaric/xargo).

Clone this project.

Update `Cargo.toml` with information regarding your project:

```
[package]
name = "hello_cargo"
version = "0.1.0"
authors = ["Your Name <you@email.com>"]
edition = "2018"
```

Add the rustup target that matches your desired profile (see above table).

```
$ rustup target add i686-unknown-linux-musl
```

Mimic the below benchmark below that matches your desired profile.


## Benchmarks

My test machine:
```
$ uname -a
Linux xxxxxx 4.15.0-36-generic #39-Ubuntu SMP Mon Sep 24 16:19:09 UTC 2018 x86_64 x86_64 x86_64 GNU/Linux

$ lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 18.04.1 LTS
Release:	18.04
Codename:	bionic

$ gcc -v
Using built-in specs.
COLLECT_GCC=gcc
COLLECT_LTO_WRAPPER=/usr/lib/gcc/x86_64-linux-gnu/7/lto-wrapper
OFFLOAD_TARGET_NAMES=nvptx-none
OFFLOAD_TARGET_DEFAULT=1
Target: x86_64-linux-gnu
Configured with: ../src/configure -v --with-pkgversion='Ubuntu 7.3.0-27ubuntu1~18.04' --with-bugurl=file:///usr/share/doc/gcc-7/README.Bugs --enable-languages=c,ada,c++,go,brig,d,fortran,objc,obj-c++ --prefix=/usr --with-gcc-major-version-only --program-suffix=-7 --program-prefix=x86_64-linux-gnu- --enable-shared --enable-linker-build-id --libexecdir=/usr/lib --without-included-gettext --enable-threads=posix --libdir=/usr/lib --enable-nls --with-sysroot=/ --enable-clocale=gnu --enable-libstdcxx-debug --enable-libstdcxx-time=yes --with-default-libstdcxx-abi=new --enable-gnu-unique-object --disable-vtable-verify --enable-libmpx --enable-plugin --enable-default-pie --with-system-zlib --with-target-system-zlib --enable-objc-gc=auto --enable-multiarch --disable-werror --with-arch-32=i686 --with-abi=m64 --with-multilib-list=m32,m64,mx32 --enable-multilib --with-tune=generic --enable-offload-targets=nvptx-none --without-cuda-driver --enable-checking=release --build=x86_64-linux-gnu --host=x86_64-linux-gnu --target=x86_64-linux-gnu
Thread model: posix
gcc version 7.3.0 (Ubuntu 7.3.0-27ubuntu1~18.04)

$ rustc --version
rustc 1.31.0-nightly (14f42a732 2018-10-14)

$ cargo --version
cargo 1.31.0-nightly (5dbac9888 2018-10-08)
```

To set up cross-compilation:
```
$ cat ~/.cargo/config
[target.x86_64-pc-windows-gnu]
linker = "/usr/bin/x86_64-w64-mingw32-gcc"
ar = "/usr/x86_64-w64-mingw32/bin/ar"

[target.i686-pc-windows-gnu]
linker = "/usr/bin/i686-w64-mingw32-gcc"
ar = "/usr/i686-w64-mingw32/bin/ar"
```

Sample hello world file written in C:

```
$ cat hello.c
#include <stdio.h>
int main() {
    printf("Hello, World!\n");
}
```

32-bit binaries have been built on the above-listed 64-bit test machine.


### Control Case: Native C on Linux

#### 64-bit Dynamic
```
$ gcc -o hello -Os -flto -Wl,--gc-sections -s hello.c

$ ./hello
Hello, World!

$ file hello
hello: ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, for GNU/Linux 3.2.0, BuildID[sha1]=4ac928420208c7297ee7fbe6677e4909bb0a86ac, stripped

$ ldd hello
	linux-vdso.so.1 (0x00007fffbc71a000)
	libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f7aad7a2000)
	/lib64/ld-linux-x86-64.so.2 (0x00007f7aadd95000)

$ stat --printf="%s\n" hello
6112
```

#### 32-bit Dynamic
```
$ gcc -o hello -m32 -Os -flto -Wl,--gc-sections -s hello.c

$ ./hello
Hello, World!

$ file hello
hello: ELF 32-bit LSB shared object, Intel 80386, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux.so.2, for GNU/Linux 3.2.0, BuildID[sha1]=d016548dd0e2649c193b8ea85ba5a0a6b7d15a9e, stripped

$ ldd hello
	linux-gate.so.1 (0xf7f05000)
	libc.so.6 => /lib/i386-linux-gnu/libc.so.6 (0xf7cfc000)
	/lib/ld-linux.so.2 (0xf7f07000)

$ stat --printf="%s\n" hello                              
5460
```

#### 64-bit Static
```
$ gcc -o hello -static -Os -flto -Wl,--gc-sections -s hello.c

$ ./hello
Hello, World!

$ file hello
hello: ELF 64-bit LSB executable, x86-64, version 1 (GNU/Linux), statically linked, for GNU/Linux 3.2.0, BuildID[sha1]=aef41e2ab6764bd22afe793dd06e6ef3376a1e8a, stripped

$ ldd hello
	not a dynamic executable

$ stat --printf="%s\n" hello                                 
753560
```

#### 32-bit Static
```
$ gcc -o hello -static -m32 -Os -flto -Wl,--gc-sections -s hello.c

$ ./hello
Hello, World!

$ file hello
hello: ELF 32-bit LSB executable, Intel 80386, version 1 (GNU/Linux), statically linked, for GNU/Linux 3.2.0, BuildID[sha1]=dad4d7614a08d6a33372b663bced164394e08a1d, stripped

$ ldd hello
	not a dynamic executable

$ stat --printf="%s\n" hello                                      
575456
```


### Case 1: Rust on Linux

#### 64-bit Dynamic
```
$ xargo build --release --target=x86_64-unknown-linux-gnu
   Compiling hello_cargo v0.1.0
    Finished release [optimized] target(s) in 0.97s                                                                                    

$ strip target/x86_64-unknown-linux-gnu/release/hello_cargo

$ target/x86_64-unknown-linux-gnu/release/hello_cargo
Hello, world!

$ file target/x86_64-unknown-linux-gnu/release/hello_cargo
target/x86_64-unknown-linux-gnu/release/hello_cargo: ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, for GNU/Linux 3.2.0, BuildID[sha1]=b8548fc469e6a2f3e6c11e43886f0c7aed979e88, stripped

$ ldd target/x86_64-unknown-linux-gnu/release/hello_cargo
	linux-vdso.so.1 (0x00007ffd4addd000)
	libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 (0x00007f0670551000)
	libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f0670160000)
	/lib64/ld-linux-x86-64.so.2 (0x00007f067097e000)

$ stat --printf="%s\n" target/x86_64-unknown-linux-gnu/release/hello_cargo
55440
```

#### 32-bit Dynamic
```
$ xargo build --release --target=i686-unknown-linux-gnu
   Compiling hello_cargo v0.1.0
    Finished release [optimized] target(s) in 1.29s                                                                                    

$ strip target/i686-unknown-linux-gnu/release/hello_cargo

$ target/i686-unknown-linux-gnu/release/hello_cargo
Hello, world!

$ file target/i686-unknown-linux-gnu/release/hello_cargo
target/i686-unknown-linux-gnu/release/hello_cargo: ELF 32-bit LSB shared object, Intel 80386, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux.so.2, for GNU/Linux 3.2.0, BuildID[sha1]=808cc42c6e0e034cda98a852e4d0f0a3da406513, stripped

$ ldd target/i686-unknown-linux-gnu/release/hello_cargo
	linux-gate.so.1 (0xf7f2d000)
	libpthread.so.0 => /lib/i386-linux-gnu/libpthread.so.0 (0xf7ed6000)
	libc.so.6 => /lib/i386-linux-gnu/libc.so.6 (0xf7cfa000)
	/lib/ld-linux.so.2 (0xf7f2f000)

$ stat --printf="%s\n" target/i686-unknown-linux-gnu/release/hello_cargo  
50672
```

#### 64-bit Static
```
$ cargo build --release --target=x86_64-unknown-linux-musl
   Compiling hello_cargo v0.1.0
    Finished release [optimized] target(s) in 3.01s                                                                                    

$ strip target/x86_64-unknown-linux-musl/release/hello_cargo

$ target/x86_64-unknown-linux-musl/release/hello_cargo
Hello, world!

$ file target/x86_64-unknown-linux-musl/release/hello_cargo
target/x86_64-unknown-linux-musl/release/hello_cargo: ELF 64-bit LSB executable, x86-64, version 1 (GNU/Linux), statically linked, BuildID[sha1]=3c2b1868a8e56e8f29e06f990e4dc0da08b58fb3, stripped

$ ldd target/x86_64-unknown-linux-musl/release/hello_cargo
	not a dynamic executable

$ stat --printf="%s\n" target/x86_64-unknown-linux-musl/release/hello_cargo
513816
```

#### 32-bit Static
```
$ cargo build --release --target=i686-unknown-linux-musl        
   Compiling hello_cargo v0.1.0
    Finished release [optimized] target(s) in 3.10s                                                                                    

$ strip target/i686-unknown-linux-musl/release/hello_cargo

$ target/i686-unknown-linux-musl/release/hello_cargo
Hello, world!

$ file target/i686-unknown-linux-musl/release/hello_cargo
target/i686-unknown-linux-musl/release/hello_cargo: ELF 32-bit LSB executable, Intel 80386, version 1 (GNU/Linux), statically linked, BuildID[sha1]=8ec9cd5a73b88a10e23be2151f96f9f13ec3c3ca, stripped

$ ldd target/i686-unknown-linux-musl/release/hello_cargo
	not a dynamic executable

$ stat --printf="%s\n" target/i686-unknown-linux-musl/release/hello_cargo  
513180
```


### Case 2: Cross-compile Rust for Windows on Linux

It's not possible to cross-compile dynamic builds, as far as I know.

#### 64-bit Static
```
$ xargo build --release --target=x86_64-pc-windows-gnu
   Compiling hello_cargo v0.1.0
    Finished release [optimized] target(s) in 0.96s                                                                                    

$ strip target/x86_64-pc-windows-gnu/release/hello_cargo.exe

$ wine target/x86_64-pc-windows-gnu/release/hello_cargo.exe
Hello, world!

$ file target/x86_64-pc-windows-gnu/release/hello_cargo.exe
target/x86_64-pc-windows-gnu/release/hello_cargo.exe: PE32+ executable (console) x86-64 (stripped to external PDB), for MS Windows

$ ldd target/x86_64-pc-windows-gnu/release/hello_cargo.exe
	not a dynamic executable

$ stat --printf="%s\n" target/x86_64-pc-windows-gnu/release/hello_cargo.exe
82944
```

#### 32-bit Static
```
$ xargo build --release --target=i686-pc-windows-gnu
   Compiling hello_cargo v0.1.0
    Finished release [optimized] target(s) in 1.02s                                                                                    

$ strip target/i686-pc-windows-gnu/release/hello_cargo.exe

$ wine target/i686-pc-windows-gnu/release/hello_cargo.exe
Hello, world!

$ file target/i686-pc-windows-gnu/release/hello_cargo.exe
target/i686-pc-windows-gnu/release/hello_cargo.exe: PE32 executable (console) Intel 80386 (stripped to external PDB), for MS Windows

$ ldd target/i686-pc-windows-gnu/release/hello_cargo.exe
	not a dynamic executable

$ stat --printf="%s\n" target/i686-pc-windows-gnu/release/hello_cargo.exe  
59406
```


### Case 3: Rust on Windows via GNU

Not attempted yet.  Feel free to submit a pull request with this data.

#### 64-bit Dynamic
```
$ RUSTFLAGS='-C target-feature=-crt-static' cargo build --release --target x86_64-pc-windows-gnu
$ strip target/x86_64-pc-windows-gnu/release/hello_cargo
```

#### 32-bit Dynamic
```
$ RUSTFLAGS='-C target-feature=-crt-static' cargo build --release --target i686-pc-windows-gnu
$ strip target/i686-pc-windows-gnu/release/hello_cargo
```

#### 64-bit Static
```
$ RUSTFLAGS='-C target-feature=+crt-static' cargo build --release --target x86_64-pc-windows-gnu
$ strip target/x86_64-pc-windows-gnu/release/hello_cargo
```

#### 32-bit Static
```
$ RUSTFLAGS='-C target-feature=+crt-static' cargo build --release --target i686-pc-windows-gnu
$ strip target/i686-pc-windows-gnu/release/hello_cargo
```


### Case 4: Rust on Windows via MSVC

Not attempted yet.  Feel free to submit a pull request with this data.

#### 64-bit Dynamic
```
$ RUSTFLAGS='-C target-feature=-crt-static' cargo build --release --target x86_64-pc-windows-msvc
$ strip target/x86_64-pc-windows-msvc/release/hello_cargo
```

#### 32-bit Dynamic
```
$ RUSTFLAGS='-C target-feature=-crt-static' cargo build --release --target i686-pc-windows-msvc
$ strip target/i686-pc-windows-msvc/release/hello_cargo
```

#### 64-bit Static
```
$ RUSTFLAGS='-C target-feature=+crt-static' cargo build --release --target x86_64-pc-windows-msvc
$ strip target/x86_64-pc-windows-msvc/release/hello_cargo
```

#### 32-bit Static
```
$ RUSTFLAGS='-C target-feature=+crt-static' cargo build --release --target i686-pc-windows-msvc
$ strip target/i686-pc-windows-msvc/release/hello_cargo
```


### Control Case: Native C on Windows

Not attempted yet.  Feel free to submit a pull request with this data.


## Resources

rustup

* [Taking Rust everywhere with rustup - The Rust Programming Language Blog](https://blog.rust-lang.org/2016/05/13/rustup.html)

Guides

* [James Munns - Tiny Rocket](https://jamesmunns.com/blog/tinyrocket/)
* [Rustlog : Why is a Rust executable large?](https://lifthrasiir.github.io/rustlog/why-is-a-rust-executable-large.html)
* [Rust staticlibs and optimizing for size - Rust Internals](https://internals.rust-lang.org/t/rust-staticlibs-and-optimizing-for-size/5746)

Reference

* [Frequently Asked Questions · The Rust Programming Language - Why do Rust programs have larger binary sizes than C programs?](https://www.rust-lang.org/en-US/faq.html#why-do-rust-programs-have-larger-binary-sizes-than-C-programs)
* [Custom Allocators](https://doc.rust-lang.org/1.9.0/book/custom-allocators.html)
* [Linkage - The Rust Reference](https://doc.rust-lang.org/reference/linkage.html)
* [rfcs/1721-crt-static.md at master · rust-lang/rfcs](https://github.com/rust-lang/rfcs/blob/master/text/1721-crt-static.md)

Cross-compilation

* [japaric/rust-cross: Everything you need to know about cross compiling Rust programs!](https://github.com/japaric/rust-cross)
