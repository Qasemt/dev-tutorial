* [link1](https://gitpig.com/gitpig/dtm/commit/21805cee291b1bc357b52e51be1a3b4bf2544384.patch)
* [link2](https://gitpig.com/gitpig/dtm/src/branch/main/.github/workflows/docker.yml )
* [rasbperry build](https://github.com/goreleaser/goreleaser-cross-example/blob/master/.goreleaser.yaml)
* [archive custom](https://goreleaser.com/customization/archive/)
---

1. Create file in root project **.release.help.yml**
``` yaml 
# .release.help.yml
# env:
#   - GO111MODULE=on

project_name: AppServer

# gomod:
#   proxy: true

builds:
  - id: app_amd64
    env: [CGO_ENABLED=0]
    goos:
      - linux
      # - windows
    goarch:
      - amd64
    dir: .
    main: main.go
    ldflags:
      - -s -w -X main.version={{.Version}} -X main.commit={{.Commit}} -X main.date={{.Date}} -X main.builtBy=goreleaser

  - id: linux-armhf-raspberry
    main: main.go
    binary: golang-cross
    goos:
      - linux
    goarch:
      - arm
    goarm:
      - 7
    env:
      - CC=arm-linux-gnueabihf-gcc
      - CXX=arm-linux-gnueabihf-g++
      - CGO_CFLAGS=--sysroot=/sysroot/linux/armhf
      - CGO_LDFLAGS=--sysroot=/sysroot/linux/armhf
      - PKG_CONFIG_SYSROOT_DIR=/sysroot/linux/armhf
      - PKG_CONFIG_PATH=/sysroot/linux/armhf/opt/vc/lib/pkgconfig:/sysroot/linux/armhf/usr/lib/arm-linux-gnueabihf/pkgconfig:/sysroot/linux/armhf/usr/lib/pkgconfig:/sysroot/linux/armhf/usr/local/lib/pkgconfig
    flags:
      - -mod=readonly
    ldflags:
      - -s -w -X main.version={{.Version}} -X main.commit={{.Commit}} -X main.date={{.Date}} -X main.builtBy=goreleaser

archives:
  - id: my-archive
    format: zip

```
2. Create file in (release.yml) **github/workflows/**

```yaml  
name: Release
on:
  create:
    tags:
       - 'v*.*.*'

jobs:
  release:
    name: Release on GitHub
    runs-on: ubuntu-latest
    steps:
      - name: Check out code
        uses: actions/checkout@v1

      - name: Validates GO releaser config
        uses: docker://goreleaser/goreleaser:latest
        with:
         args: check 

      - name: Create release on GitHub
        uses: docker://goreleaser/goreleaser:latest
        with:
          args: release -f .release.help.yml  
        env:
          GITHUB_TOKEN: ${{secrets.GITHUB_TOKEN}}

```
