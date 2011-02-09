;;; emacspeak-setup.el --- Setup Emacspeak environment --loaded to start Emacspeak
;;; $Id: emacspeak-setup.el 6482 2010-05-03 17:16:29Z tv.raman.tv $
;;; $Author: tv.raman.tv $
;;; Description:  File for setting up and starting Emacspeak
;;; Keywords: Emacspeak, Setup, Spoken Output
;;{{{  LCD Archive entry:
;;; LCD Archive Entry:
;;; emacspeak| T. V. Raman |raman@cs.cornell.edu
;;; A speech interface to Emacs |
;;; $Date: 2008-06-06 19:00:23 -0700 (Fri, 06 Jun 2008) $ |
;;;  $Revision: 4532 $ |
;;; Location undetermined
;;;

;;}}}
;;{{{  Copyright:

;;;Copyright (C) 1995 -- 2009, T. V. Raman
;;; Copyright (c) 1994, 1995 by Digital Equipment Corporation.
;;; All Rights Reserved.
;;;
;;; This file is not part of GNU Emacs, but the same permissions apply.
;;;
;;; GNU Emacs is free software; you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 2, or (at your option)
;;; any later version.
;;;
;;; GNU Emacs is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Emacs; see the file COPYING.  If not, write to
;;; the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

;;}}}
;;{{{ Introduction

;;; Commentary:
;;; Entry point for Emacspeak.

;;; Code:

;;}}}
;;{{{ Required Modules

(eval-when-compile (require 'cl))
(declaim  (optimize  (safety 0) (speed 3)))
(require 'custom)
(eval-when (compile)
  (require 'emacspeak-preamble))

;;}}}
;;{{{  Define locations

;;;###autoload
(defvar emacspeak-directory
  (expand-file-name "../" (file-name-directory load-file-name))
  "Directory where emacspeak is installed. ")
;;;###autoload
(defvar emacspeak-lisp-directory
  (expand-file-name  "lisp/" emacspeak-directory)
  "Directory where emacspeak lisp files are  installed. ")
;;;###autoload
(defvar emacspeak-sounds-directory
  (expand-file-name  "sounds/" emacspeak-directory)
  "Directory containing auditory icons for Emacspeak.")
;;;###autoload
(defvar emacspeak-xslt-directory
  (expand-file-name "xsl/" emacspeak-directory)
  "Directory holding XSL transformations.")

;;;###autoload
(defvar emacspeak-etc-directory
  (expand-file-name  "etc/" emacspeak-directory)
  "Directory containing miscellaneous files  for
  Emacspeak.")
;;;###autoload
(defvar emacspeak-servers-directory
  (expand-file-name  "servers/" emacspeak-directory)
  "Directory containing speech servers  for
  Emacspeak.")
;;;###autoload
(defvar emacspeak-info-directory
  (expand-file-name  "info/" emacspeak-directory)
  "Directory containing  Emacspeak info files.")
;;;###autoload
(defvar emacspeak-resource-directory (expand-file-name "~/.emacspeak/")
  "Directory where Emacspeak resource files such as
pronunciation dictionaries are stored. ")
;;;###autoload
(defvar emacspeak-readme-file
  (expand-file-name "README"
                    emacspeak-directory)
  "README file from where we get SVN revision number.")

;;;###autoload
(defconst emacspeak-version
  (eval-when-compile
    (format
     "32.0 %s"
     (cond
      ((file-exists-p emacspeak-readme-file)
       (let ((buffer (find-file-noselect emacspeak-readme-file))
             (revision nil))
         (save-excursion
           (set-buffer buffer)
           (goto-char (point-min))
           (setq revision
                 (format "Revision %s"
                         (or
                          (nth 2 (split-string
                                  (buffer-substring-no-properties
                                   (line-beginning-position)
                                   (line-end-position))))
                          "unknown"))))
         (kill-buffer buffer)
         revision))
      (t ""))))
  "Version number for Emacspeak.")

;;;###autoload
(defconst emacspeak-codename
  "LuckyDog"
  "Code name of present release.")

;;}}}
;;{{{ speech rate

(defcustom outloud-default-speech-rate 50
  "Default speech rate for outloud."
  :group 'tts
  :type 'integer)

(defcustom multispeech-default-speech-rate 225
  "Default speech rate for multispeech."
  :group 'tts
  :type 'integer)

(defcustom mac-default-speech-rate 225
  "Default speech rate for mac."
  :group 'tts
  :type 'integer)

(defcustom dectalk-default-speech-rate 225
  "*Default speech rate at which TTS is started. "
  :group 'tts
  :type 'integer)

(defcustom espeak-default-speech-rate 170
  "Default speech rate for eSpeak."
  :group 'tts
  :type 'integer)

(defvar tts-default-speech-rate dectalk-default-speech-rate
  "Setup on a per engine basis.")

;;}}}
;;{{{ Hooks

(add-to-list 'load-path emacspeak-lisp-directory )
(add-to-list 'load-path (expand-file-name "g-client" emacspeak-lisp-directory ))

(load-library "emacspeak")

(defvar dtk-startup-hook nil)
(defun emacspeak-tts-startup-hook ()
  "Default hook function run after TTS is started."
  (tts-configure-synthesis-setup)
  (dtk-set-rate tts-default-speech-rate t)
  (dtk-interp-sync))

(add-hook 'dtk-startup-hook
          'emacspeak-tts-startup-hook)

(defvar emacspeak-startup-hook nil)
(defun emacspeak-setup-header-line ()
  "Set up Emacspeak to show a default header line."
  (declare (special emacspeak-use-header-line
                    default-header-line-format
                    emacspeak-default-header-line-format))
  (when emacspeak-use-header-line
    (setq default-header-line-format
          emacspeak-default-header-line-format)))
(defun emacspeak-tvr-startup-hook ()
  "Emacspeak startup hook that I use."
  (load-library "emacspeak-alsaplayer")
  (load-library "emacspeak-webmarks")
  (load-library "emacspeak-webspace"))

(add-hook 'emacspeak-startup-hook 'emacspeak-setup-header-line)
(add-hook 'emacspeak-startup-hook 'emacspeak-tvr-startup-hook)
          
;;; Use (add-hook 'emacspeak-startup-hook ...)
;;; to add your personal settings.

;;}}}
(emacspeak)
(provide 'emacspeak-setup)
;;{{{  emacs local variables

;;; local variables:
;;; major-mode: emacs-lisp-mode
;;; folded-file: t
;;; end:

;;}}}
