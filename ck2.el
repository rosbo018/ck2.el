(require 'smie)
;;; keyword list taken from the notepad++ version
(require 'ck2-keywords-file)
(defconst ck2-mode-syntax-table
  (let ((table (make-syntax-table)))
    (modify-syntax-entry ?\" "\"" table)
    (modify-syntax-entry ?\# "<" table)
    (modify-syntax-entry ?\n ">" table)
    table))

(setq ck2-smie-grammer
      (smie-prec2->grammar
       (smie-bnf->prec2
        `((id)
          (insts (inst) ( insts " " insts))
          (inst ("{" inst "}")))
        '((assoc " ")))))

(defun smie-sample-rules (kind token)
  "Perform indentation of KIND on TOKEN using the `smie' engine."
  (pcase (list kind token)
    ;; ('(:after "\n")
    ;;  (smie-rule-parent))
    (`(:list-intro . ,_) t)
    (`(:elem arg) 0)
    (`(:elem basic) 4)))

(defun ck2--regexp-opt (strings)
  (regexp-opt strings 'symbols))

(defvar ck2-keywords-rx (ck2--regexp-opt ck2-keywords))

(defvar ck2-font-lock-keywords
  `((,(regexp-opt '("if" "else" "else_if" "OR" "AND" "NOT" "NOR" "NAND" "FROM" "ROOT" "trigger" "trigger_switch" "break" "while" "limit" "preferred_limit" "which" "earmark" "random" "random_list" "score_value" "hidden_tooltip" "custom_tooltip" "conditional_tooltip" "show_scope_change" "show_only_failed_conditions" "generate_tooltip" "hidden_effect" "DUKE" ) 'symbols) . font-lock-keyword-face)
    (,(regexp-opt '("PREV")) . font-lock-keyword-face)
    (,(regexp-opt '("FROM")) . font-lock-keyword-face)

    (,ck2-keywords-rx . font-lock-builtin-face)
    
    (,(rx bow (one-or-more digit) eow) . font-lock-constant-face)
    (,(rx bow (or "yes" "no") eow) . font-lock-constant-face)
    ))

(define-derived-mode ck2-mode prog-mode "simple ck2 mode"
  :syntax-table ck2-mode-syntax-table
  (setq comment-start "#"
        comment-end "")
  (smie-setup ck2-smie-grammer #'smie-sample-rules)
  (set (make-local-variable 'font-lock-defaults) '(ck2-font-lock-keywords))
  (font-lock-mode)
  (font-lock-ensure (point-min) (point-max)))
