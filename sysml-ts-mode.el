;;; sysml-ts-mode.el --- Major mode for SysML v2 using tree-sitter  -*- lexical-binding: t; -*-

;; Copyright (C) 2025 sysml-ts-mode contributors

;; Author: Petr Mukhachev
;; Version: 0.1.0
;; Package-Requires: ((emacs "30.1"))
;; Keywords: languages
;; URL: https://gitlab.com/nomograph/sysml-ts-mode

;;; Commentary:

;; Major mode for SysML v2 (.sysml) and KerML (.kerml) files, powered
;; by the tree-sitter-sysml grammar.
;;
;; To install the grammar:
;;
;;   M-x treesit-install-language-grammar RET sysml RET
;;
;; The grammar source is registered automatically when this package loads.

;;; Code:

(require 'treesit)

;;; Customization

(defgroup sysml nil
  "Support for the SysML v2 modelling language."
  :group 'languages
  :prefix "sysml-ts-")

;;; Grammar registration

(add-to-list 'treesit-language-source-alist
             '(sysml "https://gitlab.com/nomograph/tree-sitter-sysml"
                     "main" "src"))

;;; Syntax table

(defvar sysml-ts-mode--syntax-table
  (let ((st (make-syntax-table)))
    ;; // line comments and /* */ block comments
    (modify-syntax-entry ?/ ". 124b" st)
    (modify-syntax-entry ?* ". 23" st)
    (modify-syntax-entry ?\n "> b" st)
    ;; _ is a word constituent (identifiers like My_Part)
    (modify-syntax-entry ?_ "w" st)
    st)
  "Syntax table for `sysml-ts-mode'.")

;;; Major mode

;;;###autoload
(define-derived-mode sysml-ts-mode prog-mode "SysML[ts]"
  "Major mode for editing SysML v2 files, powered by tree-sitter.

To install the grammar:
  M-x treesit-install-language-grammar RET sysml RET

\\{sysml-ts-mode-map}"
  :syntax-table sysml-ts-mode--syntax-table
  :group 'sysml

  (setq-local comment-start "// ")
  (setq-local comment-end "")
  (setq-local comment-start-skip "\\(?://+\\|/\\*+\\)\\s-*")
  (setq-local comment-multi-line t)

  (when (treesit-ready-p 'sysml)
    (treesit-parser-create 'sysml)
    (treesit-major-mode-setup)))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.sysml\\'" . sysml-ts-mode))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.kerml\\'" . sysml-ts-mode))

(provide 'sysml-ts-mode)
;;; sysml-ts-mode.el ends here
