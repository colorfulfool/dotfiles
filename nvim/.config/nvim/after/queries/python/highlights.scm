; extends

; Upstream only captures the final identifier of a dotted decorator, so
; `@app.post(...)` renders `app.` in Normal. Capture the whole dotted name.

((decorator
  (attribute) @attribute)
  (#set! priority 101))

((decorator
  (call
    function: (attribute) @attribute))
  (#set! priority 101))
