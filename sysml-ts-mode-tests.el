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

(provide 'sysml-ts-mode-tests)
;;; sysml-ts-mode-tests.el ends here
