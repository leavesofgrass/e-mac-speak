;;; dtk-interp.el --- Language specific (e.g. TCL) interface to speech server
;;; $Id: dtk-interp.el 6342 2009-10-20 19:12:40Z tv.raman.tv $
;;; $Author: tv.raman.tv $
;;; Description:  Interfacing to the speech server
;;; Keywords: TTS, Dectalk, Speech Server
;;{{{  LCD Archive entry:

;;; LCD Archive Entry:
;;; emacspeak| T. V. Raman |raman@cs.cornell.edu
;;; A speech interface to Emacs |
;;; $Date: 2008-03-11 18:41:19 -0700 (Tue, 11 Mar 2008) $ |
;;;  $Revision: 4670 $ |
;;; Location undetermined
;;;

;;}}}
;;{{{  Copyright:

;;;Copyright (C) 1995 -- 2009, T. V. Raman
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;{{{ introduction

;;; All requests to the speech server are factored out into
;;; this module.
;;; These calls are declared here as defsubst so they are
;;; inlined by the byte compiler.
;;; This preserves the same level of efficiency as before,
;;; but gives us the flexibility to call out to different
;;; speech servers.

;;}}}
;;{{{ requires

;;;Code:

(require 'cl)
(declaim  (optimize  (safety 0) (speed 3)))

;;}}}
;;{{{ macros

(defmacro tts-with-punctuations (setting &rest body)
  "Safely set punctuation mode for duration of body form."
  `(progn
     (declare (special dtk-punctuation-mode))
     (let    ((save-punctuation-mode dtk-punctuation-mode))
       (unwind-protect
           (progn
             (unless (eq ,setting save-punctuation-mode)
               (process-send-string dtk-speaker-process
                                    (format "tts_set_punctuations %s  \n "
                                            ,setting))
               (setq dtk-punctuation-mode ,setting))
             ,@body
             (dtk-force))
         (unless (eq  ,setting  save-punctuation-mode)
           (setq dtk-punctuation-mode save-punctuation-mode)
           (process-send-string dtk-speaker-process
                                (format "tts_set_punctuations %s  \n "
                                        dtk-punctuation-mode ))
           (dtk-force))))))

;;}}}
;;{{{ silence

(defsubst dtk-interp-silence (duration force)
  (declare (special dtk-speaker-process))
  (process-send-string dtk-speaker-process
                       (format "sh %d%s\n"
                               duration
                               (if force "\nd" ""))))

;;}}}
;;{{{  tone

(defsubst dtk-interp-tone (pitch duration &optional force)
  (declare (special dtk-speaker-process))
  (process-send-string dtk-speaker-process
                       (format "t %d %d%s\n"
                               pitch duration
                               (if force "\nd" ""))))
;;}}}
;;{{{  queue

(defsubst dtk-interp-queue (text)
  (declare (special dtk-speaker-process))
  (process-send-string dtk-speaker-process
                       (format "q {%s }\n"
                               text)))

(defsubst dtk-interp-queue-set-rate(rate)
  (declare (special dtk-speaker-process))
  (process-send-string dtk-speaker-process
                       (format "r {%s}\n" rate)))

;;}}}
;;{{{  speak

(defsubst dtk-interp-speak ()
  (declare (special dtk-speaker-process))
  (process-send-string dtk-speaker-process
                       "d\n"))

;;}}}
;;{{{ say

(defsubst dtk-interp-say (string)
  (declare (special dtk-speaker-process))
  (process-send-string dtk-speaker-process
                       (format  "tts_say { %s}\n"
                                string )))

;;}}}
;;{{{ dispatch

;;;synonym for above in current server:
(defsubst dtk-interp-dispatch (string)
  (declare (special dtk-speaker-process))
  (process-send-string dtk-speaker-process
                       (format  "tts_say { %s}\n"
                                string )))

;;}}}
;;{{{ stop

(defsubst dtk-interp-stop ()
  (declare (special dtk-speaker-process))
  (process-send-string dtk-speaker-process "s\n" ))

;;}}}
;;{{{ sync

(defsubst dtk-interp-sync()
  (declare (special dtk-speaker-process
                    dtk-punctuation-mode dtk-speech-rate
                    dtk-capitalize dtk-split-caps
                    dtk-allcaps-beep))
  (process-send-string dtk-speaker-process
                       (format "tts_sync_state %s %s %s %s %s \n"
                               dtk-punctuation-mode
                               (if dtk-capitalize 1  0 )
                               (if dtk-allcaps-beep 1  0 )
                               (if dtk-split-caps 1 0 )
                               dtk-speech-rate)))

;;}}}
;;{{{  letter

(defsubst dtk-interp-letter (letter)
  (declare (special dtk-speaker-process))
  (process-send-string dtk-speaker-process
                       (format "l {%s}\n" letter )))

;;}}}
;;{{{  language

(defsubst dtk-interp-next-language (&optional say_it)
  (declare (special dtk-speaker-process))
  (process-send-string dtk-speaker-process
                       (format "set_next_lang %s\n" say_it)))

(defsubst dtk-interp-previous-language (&optional say_it)
  (declare (special dtk-speaker-process))
  (process-send-string dtk-speaker-process
                       (format "set_previous_lang %s\n" say_it )))

(defsubst dtk-interp-language (language say_it)
  (declare (special dtk-speaker-process))
  (process-send-string dtk-speaker-process
                       (format "set_lang %s %s \n" language say_it)))

(defsubst dtk-interp-preferred-language (alias language)
  (declare (special dtk-speaker-process))
  (process-send-string dtk-speaker-process
                       (format "set_preferred_lang %s %s \n" alias language )))

(defsubst dtk-interp-list-language ()
  (declare (special dtk-speaker-process))
  (process-send-string dtk-speaker-process
                       (format "list_lang\n" )))

;;}}}
;;{{{  rate

(defsubst dtk-interp-say-version ()
  "Speak version."
  (declare (special dtk-speaker-process))
  (process-send-string dtk-speaker-process "version\n"))

(defsubst dtk-interp-set-rate (rate)
  (declare (special dtk-speaker-process))
  (process-send-string dtk-speaker-process
                       (format "tts_set_speech_rate %s\n"
                               rate)))

;;}}}
;;{{{ character scale

(defsubst dtk-interp-set-character-scale (factor)
  (declare (special dtk-speaker-process))
  (process-send-string dtk-speaker-process
                       (format "tts_set_character_scale %s\n"
                               factor)))

;;}}}
;;{{{  split caps

(defsubst dtk-interp-toggle-split-caps (dtk-split-caps)
  (declare (special dtk-speaker-process))
  (process-send-string dtk-speaker-process
                       (format "tts_split_caps %s\n"
                               (if dtk-split-caps 1 0 ))))

;;}}}
;;{{{ capitalization

(defsubst dtk-interp-toggle-capitalization (dtk-capitalize)
  (declare (special dtk-speaker-process))
  (process-send-string dtk-speaker-process
                       (format "tts_capitalize  %s\n"
                               (if dtk-capitalize  1 0 ))))

;;}}}
;;{{{ allcaps beep

(defsubst dtk-interp-toggle-allcaps-beep  (dtk-allcaps-beep)
  (declare (special dtk-speaker-process))
  (process-send-string dtk-speaker-process
                       (format "tts_allcaps_beep  %s\n"
                               (if dtk-allcaps-beep  1 0
                                   ))))

;;}}}
;;{{{ punctuations

(defsubst dtk-interp-set-punctuations(mode)
  (declare (special dtk-speaker-process))
  (process-send-string dtk-speaker-process
                       (format "tts_set_punctuations %s\n"
                               mode)))

;;}}}
;;{{{ reset

(defsubst dtk-interp-reset-state ()
  (declare (special dtk-speaker-process))
  (process-send-string dtk-speaker-process "tts_reset \n"))

;;}}}
;;{{{ pause

(defsubst dtk-interp-pause ()
  (declare (special dtk-speaker-process))
  (process-send-string dtk-speaker-process
                       "tts_pause\n"))

;;}}}
;;{{{ resume

(defsubst dtk-interp-resume ()
  (declare (special dtk-speaker-process))
  (process-send-string dtk-speaker-process
                       "tts_resume\n"))

;;}}}

(provide 'dtk-interp)
;;{{{  local variables

;;; local variables:
;;; folded-file: t
;;; byte-compile-dynamic: t
;;; end:

;;}}}
