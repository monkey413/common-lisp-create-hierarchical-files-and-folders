(proclaim '(optimize speed)) 

(defmacro for (var start stop &body body)
  (let ((gstop (gensym)))
    `(do ((,var ,start (1+ ,var))
          (,gstop ,stop))
         ((> ,var ,gstop))
       ,@body)))

(ql:quickload "cl-utilities")
(ql:quickload "getopt")
  

(defun createDirOrFile (path)
  (if (equal (file-namestring path) "")
      (ensure-directories-exist path)
      (with-open-file (stream path :direction :output :if-exists nil))
      ))

(defun getFileLines (file)
  (let ((in (open file)) (lines nil))
    (when in
      (loop for line = (read-line in nil)
         while line do (push (cl-utilities:split-sequence #\Tab line) lines)))
    (close in)
    (setf lines (reverse lines))
    lines))

(defun main ()
  (let* ((file (probe-file (cdr (assoc "i" (multiple-value-bind (args options)
                                             (getopt:getopt *posix-argv* '(("i" :required))) options) :test #'equal))))
           (fileLines (getFileLines file))
           (maxDepth (apply #'max (mapcar #'length fileLines)))
           (prefix ""))
    (for j 0 (- maxDepth 2)
      (setf prefix "")
      (dolist (i fileLines)
        (block continue
          (if (null (nth j i)) (return-from continue))
          (if (equal (nth j i) "") (setf (nth j i) prefix))
          (if (and (nth j i) (not (equal (nth j i) ""))) (setf prefix (nth j i)) )
          ))
      )
    (setf fileLines  (mapcar #'(lambda (x) (apply #'concatenate 'string "./" x)) fileLines))
    (dolist (path fileLines) (createDirOrFile path))))

(main)
