# sysml-mode

Emacs major mode for [SysML v2](https://www.omgsysml.org/) (`.sysml`) and
KerML (`.kerml`) files, powered by the
[tree-sitter-sysml](https://gitlab.com/nomograph/tree-sitter-sysml) grammar.

**Requires Emacs 30.1+.**

## Installation

### Install the grammar

Once the package is loaded, register and compile the grammar:

```
M-x treesit-install-language-grammar RET sysml RET
```

This requires `git` and a C compiler.

### Install the package

#### From source

```elisp
(add-to-list 'load-path "/path/to/sysml-mode")
(require 'sysml-mode)
```

#### Elpaca

With Elpaca's `use-package` integration enabled:

```elisp
(use-package sysml-mode
  :ensure (:host github :repo "rolling-robot/sysml-mode"))
```

Without `use-package`:

```elisp
(elpaca (sysml-mode :host github :repo "rolling-robot/sysml-mode"))
```

Elpaca installs packages asynchronously, so run
`M-x treesit-install-language-grammar RET sysml RET` once it has finished
loading.

#### MELPA (forthcoming)

```elisp
(package-install 'sysml-mode)
```

## LSP support (Eglot)

`sysml-mode` registers the [OpenSysML](https://github.com/Open-MBEE/OpenSysML)
language server (`sysml-lsp`) automatically when Eglot is loaded.

### Install sysml-lsp

Install with Go; the binary lands in `~/go/bin`, which must be on your PATH:

```sh
go install github.com/Open-MBEE/OpenSysML/cmd/sysml-lsp@latest
```

Verify the installation:

```sh
sysml-lsp -version
```

### Start Eglot

Eglot starts automatically when a SysML file is opened and the
`sysml-lsp-server` executable is found on `exec-path`. To disable that and
start it manually with `M-x eglot`:

```elisp
(setq sysml-eglot-auto-start nil)
```

### Custom server

If `sysml-lsp` is not on your PATH, or to use another server such as
[spec42](https://github.com/elan8/spec42), set `sysml-lsp-server` before Eglot
connects:

```elisp
(setq sysml-lsp-server (list (expand-file-name "~/go/bin/sysml-lsp")))
(setq sysml-lsp-server '("spec42" "lsp"))
```

## Usage

Opening any `.sysml` or `.kerml` file automatically activates `sysml-mode`.
The mode requires the tree-sitter grammar to be installed; without it the buffer
falls back to `prog-mode` behaviour.

## Development

```
make compile   # byte-compile, zero warnings required
make test      # run ERT test suite
make clean     # remove .elc files
```

## License

GPL-3.0-or-later — see [LICENSE](LICENSE).
