# wishlist

Agent Browser–based wishlist price tracking prototype for low-frequency personal use.

This repository contains an MVP skill scaffold focused on one thing first: a lightweight login-refresh loop.

Core flow:

1. You manually complete the initial login in a dedicated browser profile.
2. The agent reuses that profile for periodic checks.
3. If login expires, the agent captures evidence and sends you an email.
4. You re-authorize once, and the next scheduled run continues.

See `agent-browser-wishlist-skill/README.md` for detailed setup and usage.
