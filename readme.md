# GoLink

The simplest possible way to add libraries to your Go project.

No environment variables, no extra config files, and your contributors won't even need to know about it.

## How?

GoLink adds libraries as a git submodule, and drafts a tiny build script.

To kick off a new project, enter the project and package names:
```bash
$ golink create example kofalt.com
Creating example in package kofalt.com
Building example...
This is an example program generated by GoLink.
```

To add a new library, just add its clone URL and package name:
```bash
$ golink add https://github.com/polydawn/pogo polydawn.net/pogo
Adding polydawn.net/pogo from https://github.com/polydawn/pogo
Cloning into '.gopath/src/polydawn.net/pogo'...
```

Anyone who has golang installed can build your project!
```bash
$ git clone https://github.com/kofalt/golink && cd golink
$ ./goad
```

This build will be isolated and repeatable.

Your GOPATH (if any) is not modified by this tool. GoLink plays well with others!

## Why?

By default, the Go toolchain requires environment variables dictating a single folder to hold all libraries & tools, basically reinventing the JAVA_HOME problem. As a result, the community has invented numerous options for adding critical features like isolation & repeatability.

This is not an exhaustive comparison - just explaining the motivations behind GoLink.

Name                                                       | Config | Isolated | Vendors | Repeatable | Required to Build
---------------------------------------------------------- | ------ | -------- | ------- | ---------- | -----------------
[GoLink](https://github.com/kofalt/golink)                 | None   | Yes      | No      | Yes        | No
[Godep](https://github.com/tools/godep)                    | JSON   | No       | Yes     | Optionally | Yes
[Goop](https://github.com/nitrous-io/goop)                 | Custom | Yes      | No      | Optionally | Yes
[Johnny Deps](https://github.com/VividCortex/johnny-deps)  | Custom | No       | No      | Optionally | Yes
[Goat](https://github.com/mediocregopher/goat)             | YAML   | No       | No      | No         | Yes
[Gpm](https://github.com/pote/gpm)                         | Custom | No       | No      | Optionally | Yes

To be isolated, your tool needs to not interact with or read from any other golang libraries on the system, and not require that GOPATH be set up.
To be repeatable, your tool needs to resolve exactly one set of libraries given a version of your project.

## Features

Running the `goad` script without any parameters will build the project - using incremental build caching, which `go build` does not! Maximum fast.

Other features are available for your convenience:

```bash
$ ./goad help
Usage: ./goad [init|build|clean|test|fmt|doc] [go packages...]
```

`./goad test`, `./goad fmt`, and `./goad doc` can all optionally take a set of package names, separated by a space. This will cause them to only test, format, or document a portion of your project.

Placing multiple commands works fine as well: `./goad build test`.

## Windows

Currently, only a bash script is emitted.
The template is tiny, and if anyone wants to open a ticket or PR with a PowerShell alternative I'd gladly add it!