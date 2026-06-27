EMACS ?= emacs

.PHONY: compile test clean

compile:
	$(EMACS) -Q --batch \
	  --eval '(setq byte-compile-error-on-warn t)' \
	  -f batch-byte-compile sysml-mode.el

test:
	$(EMACS) -Q --batch \
	  -l sysml-mode.el \
	  -l sysml-mode-tests.el \
	  -f ert-run-tests-batch-and-exit

clean:
	rm -f *.elc
