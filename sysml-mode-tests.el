;;; sysml-mode-tests.el --- ERT tests for sysml-mode  -*- lexical-binding: t; -*-

;;; Code:

(require 'ert)
(require 'sysml-mode)

(ert-deftest sysml-mode-loads ()
  "sysml-mode is provided after loading."
  (should (featurep 'sysml-mode)))

(ert-deftest sysml-mode-auto-mode-alist ()
  ".sysml and .kerml extensions map to sysml-mode."
  (should (assoc "\\.sysml\\'" auto-mode-alist))
  (should (assoc "\\.kerml\\'" auto-mode-alist))
  (should (eq (cdr (assoc "\\.sysml\\'" auto-mode-alist)) 'sysml-mode))
  (should (eq (cdr (assoc "\\.kerml\\'" auto-mode-alist)) 'sysml-mode)))

(ert-deftest sysml-mode-grammar-source ()
  "sysml grammar source is registered in treesit-language-source-alist."
  (should (assq 'sysml treesit-language-source-alist)))

(ert-deftest sysml-mode-keyword-query-valid ()
  "Every keyword in `sysml-mode--keywords' is a valid grammar token."
  (skip-unless (treesit-ready-p 'sysml t))
  (with-temp-buffer
    (treesit-parser-create 'sysml)
    (should (treesit-query-compile
             'sysml
             `(,(apply #'vector sysml-mode--keywords)
               @font-lock-keyword-face)))))

(ert-deftest sysml-mode-keyword-face ()
  "Core keywords receive `font-lock-keyword-face' in a SysML buffer."
  (skip-unless (treesit-ready-p 'sysml t))
  (with-temp-buffer
    (insert "package P { part def MyPart {} action def Fire {} }")
    (sysml-mode)
    (font-lock-ensure)
    (dolist (kw '("package" "part" "def" "action"))
      (goto-char (point-min))
      (search-forward kw)
      (should (eq (get-text-property (match-beginning 0) 'face)
                  'font-lock-keyword-face)))))

(ert-deftest sysml-mode-line-comment-face ()
  "Line comments receive `font-lock-comment-face'."
  (skip-unless (treesit-ready-p 'sysml t))
  (with-temp-buffer
    (insert "package P {\n  // ran with 2025-09 release on 2025-10-20\n}\n")
    (sysml-mode)
    (font-lock-ensure)
    (goto-char (point-min))
    (search-forward "ran with")
    (should (eq (get-text-property (match-beginning 0) 'face)
                'font-lock-comment-face))))

(ert-deftest sysml-mode-block-comment-face ()
  "Block comments receive `font-lock-comment-face'."
  (skip-unless (treesit-ready-p 'sysml t))
  (with-temp-buffer
    (insert "package P {\n  /* simple flashlight model */\n}\n")
    (sysml-mode)
    (font-lock-ensure)
    (goto-char (point-min))
    (search-forward "simple flashlight")
    (should (eq (get-text-property (match-beginning 0) 'face)
                'font-lock-comment-face))))

(ert-deftest sysml-mode-doc-face ()
  "Doc comment body receives `font-lock-doc-face'."
  (skip-unless (treesit-ready-p 'sysml t))
  (with-temp-buffer
    (insert "requirement R {\n"
            "  doc /* The flashlight field of view shall be 0 - 20 degrees.*/\n"
            "}\n")
    (sysml-mode)
    (font-lock-ensure)
    (goto-char (point-min))
    (search-forward "field of view")
    (should (eq (get-text-property (match-beginning 0) 'face)
                'font-lock-doc-face))))

(ert-deftest sysml-mode-definition-faces ()
  "Definition names receive appropriate faces."
  (skip-unless (treesit-ready-p 'sysml t))
  (with-temp-buffer
    (insert "package MyPkg {\n"
            "  part def MyPart {}\n"
            "  attribute def MyAttr {}\n"
            "}\n")
    (sysml-mode)
    (font-lock-ensure)
    (goto-char (point-min))
    (search-forward "MyPkg")
    (should (eq (get-text-property (match-beginning 0) 'face) 'font-lock-type-face))
    (search-forward "MyPart")
    (should (eq (get-text-property (match-beginning 0) 'face) 'font-lock-function-name-face))
    (search-forward "MyAttr")
    (should (eq (get-text-property (match-beginning 0) 'face) 'font-lock-variable-name-face))))

(ert-deftest sysml-mode-indent-package-body ()
  "Package body members indent by `sysml-indent-offset'."
  (skip-unless (treesit-ready-p 'sysml t))
  (with-temp-buffer
    (insert "package P {\npart myPart;\n}\n")
    (sysml-mode)
    (indent-region (point-min) (point-max))
    (goto-char (point-min))
    (forward-line 1)
    (should (= (current-indentation) sysml-indent-offset))))

(ert-deftest sysml-mode-indent-closing-brace ()
  "Closing brace aligns with the opening construct."
  (skip-unless (treesit-ready-p 'sysml t))
  (with-temp-buffer
    (insert "package P {\npart myPart;\n}\n")
    (sysml-mode)
    (indent-region (point-min) (point-max))
    (goto-char (point-min))
    (forward-line 2)
    (should (= (current-indentation) 0))))

(ert-deftest sysml-mode-indent-nested ()
  "Nested blocks indent cumulatively."
  (skip-unless (treesit-ready-p 'sysml t))
  (with-temp-buffer
    (insert "package Outer {\npackage Inner {\npart x;\n}\n}\n")
    (sysml-mode)
    (indent-region (point-min) (point-max))
    (goto-char (point-min))
    (forward-line 2)
    (should (= (current-indentation) (* 2 sysml-indent-offset)))
    (forward-line 1)
    (should (= (current-indentation) sysml-indent-offset))))

(ert-deftest sysml-mode-indent-definition-body ()
  "Definition body members indent correctly."
  (skip-unless (treesit-ready-p 'sysml t))
  (with-temp-buffer
    (insert "part def Flashlight {\npart battery : Battery;\n}\n")
    (sysml-mode)
    (indent-region (point-min) (point-max))
    (goto-char (point-min))
    (forward-line 1)
    (should (= (current-indentation) sysml-indent-offset))))

(ert-deftest sysml-mode-indent-requirement-body ()
  "Requirement body members indent correctly."
  (skip-unless (treesit-ready-p 'sysml t))
  (with-temp-buffer
    (insert "requirement flashlightSpec {\nrequirement illumination;\n}\n")
    (sysml-mode)
    (indent-region (point-min) (point-max))
    (goto-char (point-min))
    (forward-line 1)
    (should (= (current-indentation) sysml-indent-offset))))

(ert-deftest sysml-mode-indent-whitespace-settings ()
  "Indentation uses spaces and `tab-width' follows `sysml-indent-offset'."
  (with-temp-buffer
    (let ((sysml-indent-offset 3))
      (sysml-mode)
      (should-not indent-tabs-mode)
      (should (= tab-width 3)))))

(ert-deftest sysml-mode-indent-no-tabs ()
  "Deeply nested lines are indented with spaces only."
  (skip-unless (treesit-ready-p 'sysml t))
  (with-temp-buffer
    (insert "package A {\npackage B {\npackage C {\npart x;\n}\n}\n}\n")
    (sysml-mode)
    (indent-region (point-min) (point-max))
    (should-not (string-search "\t" (buffer-string)))))

(ert-deftest sysml-mode-eglot-format-matches-indent ()
  "LSP formatting agrees with tree-sitter indentation."
  (skip-unless (and (treesit-ready-p 'sysml t)
                    (executable-find (car sysml-lsp-server))))
  (require 'eglot)
  (let* ((source "package P {\npart def A {\nattribute x : Real;\n}\n}\n")
         (file (make-temp-file "sysml-test" nil ".sysml" source))
         (buffer (find-file-noselect file))
         (eglot-autoshutdown t))
    (unwind-protect
        (with-current-buffer buffer
          (let ((expected (save-excursion
                            (indent-region (point-min) (point-max))
                            (prog1 (buffer-string)
                              (erase-buffer)
                              (insert source)))))
            (apply #'eglot (eglot--guess-contact))
            (eglot-format-buffer)
            (should (equal (buffer-string) expected))))
      (with-current-buffer buffer
        (when (eglot-current-server)
          (eglot-shutdown (eglot-current-server)))
        (set-buffer-modified-p nil))
      (kill-buffer buffer)
      (delete-file file))))

(ert-deftest sysml-mode-flymake-syntax-error ()
  "Flymake backend reports a diagnostic for an ERROR node."
  (skip-unless (treesit-ready-p 'sysml t))
  (with-temp-buffer
    (insert "} garbage {")
    (sysml-mode)
    (let (reported)
      (sysml-mode--flymake-backend (lambda (diags &rest _) (setq reported diags)))
      (should (> (length reported) 0))
      (should (eq (flymake-diagnostic-type (car reported)) :error)))))

(ert-deftest sysml-mode-flymake-no-errors-on-valid ()
  "Flymake backend reports no diagnostics for valid SysML."
  (skip-unless (treesit-ready-p 'sysml t))
  (with-temp-buffer
    (insert "package P {\n  part def MyPart {}\n}\n")
    (sysml-mode)
    (let (reported)
      (sysml-mode--flymake-backend (lambda (diags &rest _) (setq reported diags)))
      (should (null reported)))))

(ert-deftest sysml-mode-eglot-registered ()
  "sysml-mode is registered in eglot-server-programs after loading eglot."
  (require 'eglot)
  (should (assq 'sysml-mode eglot-server-programs)))

(ert-deftest sysml-mode-eglot-contact ()
  "Eglot server contact resolves to `sysml-lsp-server'."
  (require 'eglot)
  (let ((contact (cdr (assq 'sysml-mode eglot-server-programs))))
    (should (equal (funcall contact t nil) sysml-lsp-server))))

(provide 'sysml-mode-tests)
;;; sysml-mode-tests.el ends here
