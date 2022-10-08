* [link1](https://gitpig.com/gitpig/dtm/commit/21805cee291b1bc357b52e51be1a3b4bf2544384.patch)
* [link2](https://gitpig.com/gitpig/dtm/src/branch/main/.github/workflows/docker.yml )

---

1. Create file in root project **.release.help.yml**
``` yaml 
# .release.help.yml
project_name: app
builds:
  - id: dtm_amd64
    env: [CGO_ENABLED=0]
    goos:
      - linux
      - windows
    goarch:
      - amd64
    dir: .
    main: main.go
    ldflags:
      - -s -w -X main.Version=v{{.Version}}
  #- id: dtm_arm64
  #  env: [CGO_ENABLED=0]
  #  goos:
  #    - darwin
  #  goarch:
  #    - arm64
  #  dir: .
  #  main: main.go
  #  ldflags:
  #    - -s -w -X main.Version=v{{.Version}}
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
