;; AuctionHouse - Bidding system

(define-data-var auction-counter uint u0)

(define-map auctions uint {
    seller: principal,
    starting-bid: uint,
    highest-bid: uint,
    highest-bidder: (optional principal),
    end-block: uint,
    ended: bool
})

(define-constant ERR-BID-TOO-LOW (err u100))
(define-constant ERR-EXPIRED (err u101))

(define-public (create-auction (starting-bid uint) (duration uint))
    (let ((auction-id (var-get auction-counter)))
        (map-set auctions auction-id {
            seller: tx-sender,
            starting-bid: starting-bid,
            highest-bid: u0,
            highest-bidder: none,
            end-block: (+ block-height duration),
            ended: false
        })
        (var-set auction-counter (+ auction-id u1))
        (ok auction-id)))

(define-public (place-bid (auction-id uint) (bid-amount uint))
    (let ((auction (unwrap! (map-get? auctions auction-id) ERR-EXPIRED)))
        (asserts! (< block-height (get end-block auction)) ERR-EXPIRED)
        (asserts! (> bid-amount (get highest-bid auction)) ERR-BID-TOO-LOW)
        (try! (stx-transfer? bid-amount tx-sender (as-contract tx-sender)))
        (ok (map-set auctions auction-id 
            (merge auction {highest-bid: bid-amount, highest-bidder: (some tx-sender)})))))

(define-read-only (get-auction (auction-id uint))
    (ok (map-get? auctions auction-id)))
