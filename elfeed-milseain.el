;;; elfeed-milseain.el --- Elfeed goodies, but in irish     -*- lexical-binding: t; -*-

;; Copyright (C) 2020  sebastien

;; Author: sebastien <sebastien@weblogism.com>
;; Keywords:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;;  Elfeed extension to change its behaviour.

;;; Code:

(require 'elfeed)


(defgroup elfeed-milseain nil
  "Customisation group for elfeed-milseain."
  :group 'elfeed)

(defcustom elfeed-milseain-date-format "%d-%m-%Y"
  "Date format of the entry."
  :group 'elfeed-milseain
  :type 'string)

(define-derived-mode elfeed-milseain-mode tabulated-list-mode
  "Milseain"
  "Elfeed Milseain mode"
  (setq tabulated-list-format
        [("Date" 12 t)
         ("Feed" 22 t)
         ("Title" 75 nil)
         ("Tags" 25 t)])
  (setq tabulated-list-padding 2)
  (tabulated-list-init-header))


(defun elfeed-milseain--feed-entry-date->string (feed-entry-date)
  "Convert a FEED-ENTRY-DATE to a string using `elfeed-milseain-date-format'."
  (format-time-string elfeed-milseain-date-format
                      (seconds-to-time feed-entry-date)))

(defun elfeed-milseain--feeds->tabulated (feeds)
  "Convert a list of FEEDS to a tabulated list format."
  (mapcar (lambda (entry)
            (let ((date-entry (elfeed-milseain--feed-entry-date->string (elfeed-entry-date entry))))
              (list (elfeed-entry-id entry)
                    (vector date-entry
                            (elfeed-feed-title (elfeed-entry-feed entry))
                            (elfeed-entry-title entry)
                            (mapconcat #'symbol-name (elfeed-entry-tags entry) ","))))) feeds))

(defun elfeed-milseain--display-entries ()
  (let ((buffer (get-buffer "*elfeed-search*")))
    (with-current-buffer buffer
      (elfeed-milseain-mode)
      (elfeed-search--update-list)
      (setq tabulated-list-entries (elfeed-milseain--feeds->tabulated elfeed-search-entries))
      (tabulated-list-print t))
    (switch-to-buffer buffer)))

;;;###autoload
(defun elfeed-milseain/setup ()
  ""
  (interactive)
  (setq elfeed-search-print-entries-function #'elfeed-milseain--display-entries))

(provide 'elfeed-milseain)
;;; elfeed-milseain.el ends here
