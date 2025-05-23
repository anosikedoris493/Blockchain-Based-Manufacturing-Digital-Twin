;; Simulation Contract
;; Manages digital replicas of physical manufacturing assets

;; Data structure for simulation models
(define-map simulation-models
  { model-id: (string-ascii 32) }
  {
    equipment-id: (string-ascii 32),
    creator: principal,
    model-version: (string-ascii 20),
    creation-date: uint,
    last-updated: uint,
    parameters: (list 10 (string-ascii 50)),
    accuracy-score: uint,
    is-active: bool
  }
)

;; Data structure for simulation runs
(define-map simulation-runs
  {
    run-id: (string-ascii 32)
  }
  {
    model-id: (string-ascii 32),
    initiator: principal,
    timestamp: uint,
    input-parameters: (list 10 int),
    output-results: (list 10 int),
    run-status: (string-ascii 20)
  }
)

;; Public function to register a new simulation model
(define-public (register-model
    (model-id (string-ascii 32))
    (equipment-id (string-ascii 32))
    (model-version (string-ascii 20))
    (parameters (list 10 (string-ascii 50)))
    (accuracy-score uint))
  (let ((caller tx-sender))
    (if (map-insert simulation-models
        { model-id: model-id }
        {
          equipment-id: equipment-id,
          creator: caller,
          model-version: model-version,
          creation-date: block-height,
          last-updated: block-height,
          parameters: parameters,
          accuracy-score: accuracy-score,
          is-active: true
        })
      (ok true)
      (err u1))))

;; Public function to update a simulation model
(define-public (update-model
    (model-id (string-ascii 32))
    (model-version (string-ascii 20))
    (parameters (list 10 (string-ascii 50)))
    (accuracy-score uint))
  (let ((caller tx-sender))
    (match (map-get? simulation-models { model-id: model-id })
      model (if (is-eq caller (get creator model))
        (begin
          (map-set simulation-models
            { model-id: model-id }
            (merge model {
              model-version: model-version,
              last-updated: block-height,
              parameters: parameters,
              accuracy-score: accuracy-score
            }))
          (ok true))
        (err u2))
      (err u3))))

;; Public function to record a simulation run
(define-public (record-simulation-run
    (run-id (string-ascii 32))
    (model-id (string-ascii 32))
    (input-parameters (list 10 int))
    (output-results (list 10 int))
    (run-status (string-ascii 20)))
  (let ((caller tx-sender))
    (match (map-get? simulation-models { model-id: model-id })
      model (if (get is-active model)
        (if (map-insert simulation-runs
            { run-id: run-id }
            {
              model-id: model-id,
              initiator: caller,
              timestamp: block-height,
              input-parameters: input-parameters,
              output-results: output-results,
              run-status: run-status
            })
          (ok true)
          (err u4))
        (err u5))
      (err u6))))

;; Read-only function to get simulation model details
(define-read-only (get-model (model-id (string-ascii 32)))
  (map-get? simulation-models { model-id: model-id }))

;; Read-only function to get simulation run details
(define-read-only (get-simulation-run (run-id (string-ascii 32)))
  (map-get? simulation-runs { run-id: run-id }))
