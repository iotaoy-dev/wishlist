# Wishlist Price Tracker Skill (Agent Browser MVP)

A local-first prototype for low-frequency wishlist price checks using `agent-browser` with a persistent browser profile.

## What this MVP does

- Reuses a persistent login session via `--profile`
- Visits a product page or platform landing page
- Detects whether login appears to be invalid
- Captures a screenshot for evidence
- Sends an email notification when re-login is needed
- Gives you a manual re-auth path via browser window + login URL

## Core design

1. **You** complete the first login manually in a dedicated browser profile.
2. **Agent Browser** reuses that profile for scheduled checks.
3. If the session has expired, the script:
   - captures a screenshot
   - sends you an email with the login URL and screenshot path
   - exits with a non-zero code
4. You reopen the profile, complete login, and the next scheduled run continues.

## Why this shape

`agent-browser` supports persistent profiles, named sessions, and explicit state save/load. The project docs show `--profile`, `--session-name`, and `state save/load` as supported ways to persist auth across runs. They also describe 2FA as a manual step followed by saving state. On macOS, a persistent profile is a straightforward fit for a personal, low-frequency workflow. See the official references listed in `references.md`.

## Folder structure

- `config.example.env` — configuration template
- `wishlist.csv` — product list
- `scripts/bootstrap_login.sh` — initialize a dedicated logged-in profile
- `scripts/check_item.sh` — run one check and detect login expiry
- `scripts/check_all.sh` — iterate all items in `wishlist.csv`
- `scripts/send_mail.applescript` — Apple Mail notification helper
- `examples/launchd.plist.example` — example macOS scheduler config
- `examples/skill-template.md` — suggested SKILL.md for agent use
- `references.md` — source notes and citations

## Assumptions

- macOS
- `agent-browser` is already installed
- Apple Mail is configured locally **if** you want unattended email notifications
- You use a **dedicated browser profile** for shopping automation

## Quick start

### 1) Copy config

```bash
cp config.example.env .env
```

Edit `.env`.

### 2) Create your dedicated login profile

```bash
bash scripts/bootstrap_login.sh
```

This opens a headed browser using your dedicated profile and waits for you to finish login manually.

### 3) Add a few items to `wishlist.csv`

Use the included example rows as a starting point.

### 4) Test one item

```bash
bash scripts/check_item.sh jd-test "https://example.com/product" "https://passport.jd.com/new/login.aspx"
```

### 5) Run all items

```bash
bash scripts/check_all.sh
```

## Login-expiry detection model

This MVP uses a deliberately simple rule:

- Open the target URL with the persistent profile
- Wait for load
- Read the current URL
- If the current URL matches a known login URL pattern, treat it as expired

You can extend this later with page text checks such as “请登录”, “扫码登录”, or platform-specific selectors.

## Notification model

When login is required, the script sends an email that includes:

- item ID
- target URL
- detected current URL
- login URL to reopen
- screenshot path

The Apple Mail helper can attach the screenshot file.

## Scheduling

Use `launchd` on macOS for low-frequency scheduling. An example plist is included.

## Security notes

- Do **not** reuse your daily browser profile.
- Keep this automation to read-only tasks.
- Avoid exposing any control endpoint to the public network.
- Treat the dedicated profile as a scoped credential container.

## Next upgrades

- platform-specific login detectors
- structured extraction of visible price text
- CSV or Markdown history log
- diff screenshots for significant page changes
- webhook or SMTP notifier in addition to Apple Mail
