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

#### MELPA (forthcoming)

```elisp
(package-install 'sysml-mode)
```

## LSP support (Eglot)

`sysml-mode` registers the [spec42](https://github.com/elan8/spec42)
language server automatically when Eglot is loaded.

### Install spec42

Download the latest release for your platform and place the `spec42` binary on
your PATH:

```sh
curl -L https://github.com/elan8/spec42/releases/download/v0.32.0/spec42-0.32.0-linux-x64.tar.gz \
  | tar -xz -C ~/.local/bin
```

Verify the installation:

```sh
spec42 doctor
```

### Start Eglot

```
M-x eglot
```

To start Eglot automatically when opening SysML files:

```elisp
(add-hook 'sysml-mode-hook #'eglot-ensure)
```

### Custom server path

If `spec42` is not on your PATH, set `sysml-lsp-server` before Eglot connects:

```elisp
(setq sysml-lsp-server '("/path/to/spec42" "lsp"))
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
