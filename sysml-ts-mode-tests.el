;;; sysml-ts-mode-tests.el --- ERT tests for sysml-ts-mode  -*- lexical-binding: t; -*-

;;; Code:

(require 'ert)
(require 'sysml-ts-mode)

(ert-deftest sysml-ts-mode-loads ()
  "sysml-ts-mode is provided after loading."
  (should (featurep 'sysml-ts-mode)))

(ert-deftest sysml-ts-mode-auto-mode-alist ()
  ".sysml and .kerml extensions map to sysml-ts-mode."
  (should (assoc "\\.sysml\\'" auto-mode-alist))
  (should (assoc "\\.kerml\\'" auto-mode-alist))
  (should (eq (cdr (assoc "\\.sysml\\'" auto-mode-alist)) 'sysml-ts-mode))
  (should (eq (cdr (assoc "\\.kerml\\'" auto-mode-alist)) 'sysml-ts-mode)))

(ert-deftest sysml-ts-mode-grammar-source ()
  "sysml grammar source is registered in treesit-language-source-alist."
  (should (assq 'sysml treesit-language-source-alist)))

(ert-deftest sysml-ts-mode-keyword-query-valid ()
  "Every keyword in `sysml-ts-mode--keywords' is a valid grammar token."
  (skip-unless (treesit-ready-p 'sysml t))
  (with-temp-buffer
    (treesit-parser-create 'sysml)
    (should (treesit-query-compile
             'sysml
             `(,(apply #'vector sysml-ts-mode--keywords)
               @font-lock-keyword-face)))))

(ert-deftest sysml-ts-mode-keyword-face ()
  "Core keywords receive `font-lock-keyword-face' in a SysML buffer."
  (skip-unless (treesit-ready-p 'sysml t))
  (with-temp-buffer
    (insert "package P { part def MyPart {} action def Fire {} }")
    (sysml-ts-mode)
    (font-lock-ensure)
    (dolist (kw '("package" "part" "def" "action"))
      (goto-char (point-min))
      (search-forward kw)
      (should (eq (get-text-property (match-beginning 0) 'face)
                  'font-lock-keyword-face)))))

(ert-deftest sysml-ts-mode-line-comment-face ()
  "Line comments receive `font-lock-comment-face'."
  (skip-unless (treesit-ready-p 'sysml t))
  (with-temp-buffer
    (insert "package P {\n  // ran with 2025-09 release on 2025-10-20\n}\n")
    (sysml-ts-mode)
    (font-lock-ensure)
    (goto-char (point-min))
    (search-forward "ran with")
    (should (eq (get-text-property (match-beginning 0) 'face)
                'font-lock-comment-face))))

(ert-deftest sysml-ts-mode-block-comment-face ()
  "Block comments receive `font-lock-comment-face'."
  (skip-unless (treesit-ready-p 'sysml t))
  (with-temp-buffer
    (insert "package P {\n  /* simple flashlight model */\n}\n")
    (sysml-ts-mode)
    (font-lock-ensure)
    (goto-char (point-min))
    (search-forward "simple flashlight")
    (should (eq (get-text-property (match-beginning 0) 'face)
                'font-lock-comment-face))))

(ert-deftest sysml-ts-mode-doc-face ()
  "Doc comment body receives `font-lock-doc-face'."
  (skip-unless (treesit-ready-p 'sysml t))
  (with-temp-buffer
    (insert "requirement R {\n"
            "  doc /* The flashlight field of view shall be 0 - 20 degrees.*/\n"
            "}\n")
    (sysml-ts-mode)
    (font-lock-ensure)
    (goto-char (point-min))
    (search-forward "field of view")
    (should (eq (get-text-property (match-beginning 0) 'face)
                'font-lock-doc-face))))

(provide 'sysml-ts-mode-tests)
;;; sysml-ts-mode-tests.el ends here
