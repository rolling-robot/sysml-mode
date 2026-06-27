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

(provide 'sysml-mode-tests)
;;; sysml-mode-tests.el ends here
