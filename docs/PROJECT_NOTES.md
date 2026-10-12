# Canis Odd Music.Com — Project Notes

## Pricing
- Download: 700 UGX per music download.
- Donation: unlimited/custom amount; no fixed maximum.

## Contacts
- Email: canisodd23@gmail.com
- WhatsApp: +256 783 584 484
- Telephone: +256 783 922 220
- Location: Soroti, Uganda

## Social
YouTube, TikTok, Facebook and X/Twitter should be configured through admin settings until the exact profile URLs are confirmed.

## Production payment flow
Flutter creates a payment request -> Node.js sends it to the selected provider -> customer pays by Mobile Money/card -> provider calls the backend webhook -> backend verifies the transaction -> PostgreSQL records success -> backend creates download entitlement for a paid download or completes the donation.
