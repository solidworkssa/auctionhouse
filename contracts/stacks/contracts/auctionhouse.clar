;; AuctionHouse Clarity Contract
;; Simple auction contract with bidding.


(define-data-var highest-bid uint u0)
(define-data-var highest-bidder (optional principal) none)
(define-data-var end-block uint (+ block-height u1000))
(define-constant beneficiary tx-sender)

(define-public (bid (amount uint))
    (begin
        (asserts! (< block-height (var-get end-block)) (err u100))
        (asserts! (> amount (var-get highest-bid)) (err u101))
        
        (match (var-get highest-bidder)
            bidder (try! (as-contract (stx-transfer? (var-get highest-bid) tx-sender bidder)))
            true
        )
        
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
        (var-set highest-bid amount)
        (var-set highest-bidder (some tx-sender))
        (ok true)
    )
)

(define-public (end-auction)
    (begin
        (asserts! (>= block-height (var-get end-block)) (err u100))
        (try! (as-contract (stx-transfer? (var-get highest-bid) tx-sender beneficiary)))
        (ok true)
    )
)

