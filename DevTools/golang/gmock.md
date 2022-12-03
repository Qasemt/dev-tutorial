- [link1](https://blog.codecentric.de/gomock-tutorial)

#gmock

### requirement

install lib in project folder

```bash
$ go get github.com/golang/mock/gomock
$ go install github.com/golang/mock/mockgen
$ go get golang.org/x/tools/go/packages
```

create [_makefile_] in project folder :

> example :

```bash
mock:
	mockgen -destination ./mocks/mock_ichimoku.go   github.com/qasemt/ichimoku IIchimokuDriver

```

run makfile in terminal

```
makefile mock
```
