# Architecture (Draft)

Goal: declaratively spawn CLAWDINATOR instances on Hetzner using OpenTofu + NixOS.

Operating mode:
- declarative-first, no manual setup
- machines are created by automation (another CLAWDINATOR)

Core pieces:
- OpenTofu provisions Hetzner hosts (networks, volumes, instances).
- NixOS modules configure clawdbot + CLAWDINATOR runtime on each host.
- Shared memory is mounted at a consistent path on all hosts.

Runtime layout (planned):
- /var/lib/clawd/memory (shared hive-mind memory)
- /var/lib/clawd/runtime (instance-local temp)
- /var/lib/clawd/logs (logs)

Instance naming:
- CLAWDINATOR-{1..n}
- Daily notes can be per-instance (YYYY-MM-DD_INSTANCE.md)
- Canonical files are shared (goals, architecture, ops, etc.)

Upstream freshness:
- Nix flake input tracks `github:clawdbot/nix-clawdbot` (latest upstream).
- Update with `nix flake update` and rebuild hosts.
- Optional self-update timer is available in the Nix module.
- Self-update expects this repo to be present on the host (default: /var/lib/clawd/repo).
- Updates will refresh flake.lock; review before applying in prod.
- GitHub App tokens are refreshed via a systemd timer when enabled.
