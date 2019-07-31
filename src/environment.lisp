;;;; environment.lisp

(in-package :woo)

(defclass environment ()
  ((store :accessor environment-store
          :initform (make-hash-table :test #'equal)
          :type hash-table)
   (outer :reader environment-outer
          :initarg :outer
          :type (or null environment))))

(defun make-environment (&optional outer)
  (make-instance 'environment :outer outer))

(defmethod add-builtins ((env environment))
  (macrolet ((builtin (name &body body)
               `(set-in env ,name (list :builtin #'(lambda (args) ,@body)))))
    (builtin "len"
      (trivia:match (first args)
        ((or (list :array value)
             (list :string value))
         (length value))
        (_ (error "Not supported"))))
    (builtin "puts"
      (princ (mapc #'inspect-object args))
      +null-object+)
    (builtin "first" (first args))))

(defmethod get-from ((environment environment) (name string))
  (alexandria:if-let (outer (environment-outer environment))
    (get-from outer name)
    (gethash name (environment-store environment))))

(defmethod set-in ((environment environment) (name string) value)
  (setf (gethash name (environment-store environment)) value))
