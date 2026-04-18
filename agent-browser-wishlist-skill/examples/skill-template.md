---
name: wishlist-price-tracker
description: Reuse a dedicated shopping browser profile to validate login state, open wishlist product pages, capture evidence, and notify the owner by email if re-authentication is required.
---

# Wishlist Price Tracker

## Purpose

This skill is for personal, low-frequency wishlist monitoring on sites that are hostile to scraping. Prefer browser automation with a dedicated persistent profile over code-heavy crawling.

## Rules

1. Reuse the dedicated profile from `.env`.
2. Never use the user's main browser profile.
3. Default to read-only tasks.
4. If redirected to login, trigger the email notification flow and stop.
5. Capture a screenshot before reporting failure.
6. Do not attempt unattended credential entry unless explicitly configured for a specific site.

## Standard flow

1. Load item list from `wishlist.csv`.
2. Open each target URL with `agent-browser --profile "$AB_PROFILE"`.
3. Wait for load and read the current URL.
4. If login is required, send email via Apple Mail helper.
5. If login is valid, continue to price extraction logic.

## Commands

- Bootstrap login:
  - `bash scripts/bootstrap_login.sh <login_url>`
- Check one item:
  - `bash scripts/check_item.sh <item_id> <target_url> <login_url>`
- Check all items:
  - `bash scripts/check_all.sh`

## Expected output

- screenshot in `output/`
- log in `output/`
- email alert when auth expires
