<h1 align="center">Toolchain</h1>

<p align="center">
  Compilers, build systems, language runtimes, and CI tooling.
</p>

<p align="center">
  <a href="#c--c">C / C++</a> ·
  <a href="#python">Python</a> ·
  <a href="#nodejs--electron">Node.js & Electron</a> ·
  <a href="#go">Go</a> ·
  <a href="#electronics">Electronics</a> ·
  <a href="#cicd">CI/CD</a> ·
  <a href="#other">Other</a>
</p>

---

## C / C++

| Page | Notes |
| :--- | :--- |
| [CMake: add_library](./compile_cxx/add_library_in_cmake.md) | Linking a library target |
| [CFLAGS for Boards](./compile_cxx/cflagsForBoards.md) | Per-board compiler flags |
| [Core Dump Analysis](./compile_cxx/core_dump_crash_app.md) | Debugging a crashed app from a core dump |
| [Cygwin on Windows](./compile_cxx/cygwin_building%20on_windows_using_cygwin.md) | Building with Cygwin |
| [GDB Configuration](./compile_cxx/gdb_Config.md) | `.gdbinit` and common commands |
| [VisualGDB](./compile_cxx/visualgdb.md) | Remote debugging from Visual Studio |
| [Resolving Shared Library Links](./compile_cxx/libraryLink.md) | `ldd`, rpath, missing `.so` |
| [Makefile Example](./compile_cxx/makefile_exam.md) | Reference Makefile |
| [Boost](./compile_cxx/boost.txt) | Version notes (1.55) |
| [Pre-defined Compiler Macros](./compile_cxx/Pre_defined_Compiler_Macros.md) | `__GNUC__`, platform/arch macros |
| [Qt .pro Configuration](./compile_cxx/qtconfigpro.md) | qmake project files |
| [Qt 4.8.6 32-bit Build](./compile_cxx/build_qt4.8.6_32x.md) | Legacy Qt build for boards |
| [VS Code C++ Snippets](./compile_cxx/vscode_snippets_cpp.md) | Editor snippets |
| [FreeImage](./compile_cxx/freeimage.md) | Image library — build, crop/resize sample, CMake linking |

## Python

| Page | Notes |
| :--- | :--- |
| [Python on Boards](./Python/readme.md) | Build 3.12 from source, portable package, cross-board transfer |
| [Python on "rk_a" (Rockchip)](./Python/board/rk_a/readme.md) | Install script for that specific board |
| [Remote Python Debug Setup](./Python/RemotePythonDebugSetup.md) | `debugpy` + VS Code on a remote board |
| [venv Guide](./Python/venv-guide.md) | Creating/activating virtual environments *(Persian — pending translation)* |
| [Wheel Management](./Python/whl_managment.md) | Building/installing `.whl` packages |
| [serial_ping.py](./Python/serial_ping.py) | Serial ping/pong TX/RX pin finder — run on the board |
| [serial_ping.py without an editor](./Python/serial-ping-echo.md) | Paste-ready `echo` / heredoc blocks that write the script on a board — no `vi` needed |

## Node.js & Electron

| Page | Notes |
| :--- | :--- |
| [Node.js](./NodeJS/Nodejs.md) | Install on ARM boards, node-gyp |
| [Node.js for the BeagleBone Black](./NodeJS/Node.js_for_the_BBB.md) | Board-specific install |
| [Smartpow native modules](./NodeJS/smartpow.md) | `node-pre-gyp` build notes |
| [Electron](./NodeJS/electron.md) | Quick Start repo setup |

## Go

| Page | Notes |
| :--- | :--- |
| [Go bin Configuration](./golang/golang_bin_config.md) | Download and PATH setup |
| [GoMock](./golang/gmock.md) | Mock generation for tests |
| [GoReleaser Config](./golang/goreleaser_config.md) | Cross-compiling releases, incl. Raspberry Pi |

## Electronics

| Page | Notes |
| :--- | :--- |
| [NRF24 Library Setup](./elec/NRF24.md) | Wireless transceiver module |
| [STM32 VS Code Template](./elec/stm32_template.md) | Nucleo board project template |

## CI/CD

| Page | Notes |
| :--- | :--- |
| [Jenkins](./ci_cd_jenkins.md) | Install and configure |
| [TeamCity](./teamcity/readme.md) | Build agent installation |
| [GitLab](./git-lab/readme.md) | Install/config on Ubuntu 16.04, backup/restore |
| [GitLab HTTPS Configuration](./git-lab/https_config.md) | TLS setup |

## Other

| Page | Notes |
| :--- | :--- |
| [ReSharper License Server](./resharper_license_server.md) | JetBrains license server + hosts file |
| [NMEA Samples](./NMEASamples/) | Raw NMEA/GPS sample data — undocumented, kept for reference |
