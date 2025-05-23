;; Optimization Contract
;; Generates improved parameters for manufacturing processes

;; Data structure for optimization targets
(define-map optimization-targets
  { target-id: (string-ascii 32) }
  {
    equipment-id: (string-ascii 32),
    creator: principal,
    creation-date: uint,
    target-metrics: (list 5 (string-ascii 50)),
    constraints: (list 5 (string-ascii 100)),
    priority-weights: (list 5 uint),
    is-active: bool
  }
)

;; Data structure for optimization results
(define-map optimization-results
  { result-id: (string-ascii 32) }
  {
    target-id: (string-ascii 32),
    optimizer: principal,
    timestamp: uint,
    original-parameters: (list 10 int),
    optimized-parameters: (list 10 int),
    expected-improvement: uint,
    confidence-score: uint,
    implementation-status: (string-ascii 20)
  }
)

;; Public function to create an optimization target
(define-public (create-optimization-target
    (target-id (string-ascii 32))
    (equipment-id (string-ascii 32))
    (target-metrics (list 5 (string-ascii 50)))
    (constraints (list 5 (string-ascii 100)))
    (priority-weights (list 5 uint)))
  (let ((caller tx-sender))
    (if (map-insert optimization-targets
        { target-id: target-id }
        {
          equipment-id: equipment-id,
          creator: caller,
          creation-date: block-height,
          target-metrics: target-metrics,
          constraints: constraints,
          priority-weights: priority-weights,
          is-active: true
        })
      (ok true)
      (err u1))))

;; Public function to record optimization results
(define-public (record-optimization-result
    (result-id (string-ascii 32))
    (target-id (string-ascii 32))
    (original-parameters (list 10 int))
    (optimized-parameters (list 10 int))
    (expected-improvement uint)
    (confidence-score uint))
  (let ((caller tx-sender))
    (match (map-get? optimization-targets { target-id: target-id })
      target (if (get is-active target)
        (if (map-insert optimization-results
            { result-id: result-id }
            {
              target-id: target-id,
              optimizer: caller,
              timestamp: block-height,
              original-parameters: original-parameters,
              optimized-parameters: optimized-parameters,
              expected-improvement: expected-improvement,
              confidence-score: confidence-score,
              implementation-status: "pending"
            })
          (ok true)
          (err u2))
        (err u3))
      (err u4))))

;; Public function to update implementation status
(define-public (update-implementation-status
    (result-id (string-ascii 32))
    (status (string-ascii 20)))
  (let ((caller tx-sender))
    (match (map-get? optimization-results { result-id: result-id })
      result (if (is-eq caller (get optimizer result))
        (begin
          (map-set optimization-results
            { result-id: result-id }
            (merge result {
              implementation-status: status
            }))
          (ok true))
        (err u5))
      (err u6))))

;; Read-only function to get optimization target details
(define-read-only (get-optimization-target (target-id (string-ascii 32)))
  (map-get? optimization-targets { target-id: target-id }))

;; Read-only function to get optimization result details
(define-read-only (get-optimization-result (result-id (string-ascii 32)))
  (map-get? optimization-results { result-id: result-id }))
