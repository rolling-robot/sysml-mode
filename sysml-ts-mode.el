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

;;; Font-lock

(defvar sysml-ts-mode--font-lock-feature-list
  '((comment definition)
    (keyword)
    ()
    ())
  "Feature list for `sysml-ts-mode'.")

;; "enumeration"/"readonly" excluded — not anonymous tokens in the grammar.
;; "feature" excluded — no corresponding anonymous token (feature_usage has none).
(defconst sysml-ts-mode--keywords
  '("about" "abstract" "accept" "action" "actor" "after" "alias" "all"
    "allocate" "allocation" "analysis" "and" "as" "assert" "assign"
    "assume" "at" "attribute" "bind" "by" "calc" "case" "comment"
    "concern" "connect" "connection" "constraint" "constant" "crosses"
    "decide" "def" "default" "defined" "dependency" "derived" "do" "doc"
    "done" "else" "end" "enum" "entry" "event" "exhibit" "exit" "expose"
    "filter" "first" "flow" "for" "fork" "frame" "from" "hastype" "id"
    "if" "implies" "import" "in" "include" "individual" "inout"
    "interface" "istype" "item" "join" "language" "library" "locale"
    "loop" "merge" "message" "meta" "metadata" "new" "nonunique" "not"
    "objective" "occurrence" "of" "or" "ordered" "out" "package"
    "parallel" "part" "perform" "port" "private" "protected" "public"
    "ref" "redefines" "references" "render" "rendering" "rep" "require"
    "requirement" "return" "satisfy" "send" "snapshot" "specializes"
    "stakeholder" "standard" "state" "stream" "subsets" "subject"
    "succession" "terminate" "then" "timeslice" "to" "transition" "true"
    "false" "until" "use" "variant" "variation" "verification" "verify"
    "via" "view" "viewpoint" "when" "while" "xor")
  "SysML anonymous keyword tokens for font-lock.")

(defvar sysml-ts-mode--font-lock-settings
  (treesit-font-lock-rules
   :language 'sysml
   :feature 'comment
   '((comment) @font-lock-comment-face
     (block_comment_body) @font-lock-doc-face)

   :language 'sysml
   :feature 'keyword
   `(,(apply #'vector sysml-ts-mode--keywords) @font-lock-keyword-face)

   :language 'sysml
   :feature 'definition
   '((package_definition    (identification (name (identifier) @font-lock-type-face)))
     (library_package       (identification (name (identifier) @font-lock-type-face)))
     (part_definition       (identification (name (identifier) @font-lock-function-name-face)))
     (item_definition       (identification (name (identifier) @font-lock-function-name-face)))
     (port_definition       (identification (name (identifier) @font-lock-function-name-face)))
     (action_definition     (identification (name (identifier) @font-lock-function-name-face)))
     (state_definition      (identification (name (identifier) @font-lock-function-name-face)))
     (constraint_definition (identification (name (identifier) @font-lock-function-name-face)))
     (requirement_definition (identification (name (identifier) @font-lock-function-name-face)))
     (connection_definition (identification (name (identifier) @font-lock-function-name-face)))
     (interface_definition  (identification (name (identifier) @font-lock-function-name-face)))
     (allocation_definition (identification (name (identifier) @font-lock-function-name-face)))
     (flow_definition       (identification (name (identifier) @font-lock-function-name-face)))
     (metadata_definition   (identification (name (identifier) @font-lock-function-name-face)))
     (use_case_definition   (identification (name (identifier) @font-lock-function-name-face)))
     (calc_definition       (identification (name (identifier) @font-lock-function-name-face)))
     (view_definition       (identification (name (identifier) @font-lock-function-name-face)))
     (viewpoint_definition  (identification (name (identifier) @font-lock-function-name-face)))
     (rendering_definition  (identification (name (identifier) @font-lock-function-name-face)))
     (attribute_definition  (identification (name (identifier) @font-lock-variable-name-face)))))
  "Font-lock settings for `sysml-ts-mode'.")

;;; Indentation

(defcustom sysml-ts-indent-offset 4
  "Number of spaces for each indentation level in `sysml-ts-mode'."
  :type 'integer
  :safe #'integerp
  :group 'sysml)

(defvar sysml-ts-mode--indent-rules
  `((sysml
     ;; top-level: no indent
     ((parent-is "source_file") column-0 0)

     ;; closing brace: align with the line that opened the block
     ((node-is "}") parent-bol 0)

     ;; block bodies: indent children by one level
     ((parent-is "package_body")     parent-bol ,sysml-ts-indent-offset)
     ((parent-is "structural_body")  parent-bol ,sysml-ts-indent-offset)
     ((parent-is "action_body")      parent-bol ,sysml-ts-indent-offset)
     ((parent-is "requirement_body") parent-bol ,sysml-ts-indent-offset)
     ((parent-is "usage_body")       parent-bol ,sysml-ts-indent-offset)
     ((parent-is "state_body")       parent-bol ,sysml-ts-indent-offset)

     ;; blank lines and multi-line token interiors: inherit parent column
     (no-node parent-bol 0)))
  "Indentation rules for `sysml-ts-mode'.")

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
    (setq-local treesit-font-lock-settings sysml-ts-mode--font-lock-settings)
    (setq-local treesit-font-lock-feature-list sysml-ts-mode--font-lock-feature-list)
    (setq-local treesit-simple-indent-rules sysml-ts-mode--indent-rules)
    (treesit-major-mode-setup)))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.sysml\\'" . sysml-ts-mode))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.kerml\\'" . sysml-ts-mode))

(provide 'sysml-ts-mode)
;;; sysml-ts-mode.el ends here
