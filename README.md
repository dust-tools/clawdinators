idea of this repo is to create infrastructure to spawn CLAWDINATORS on demand.

this repo is declarative-first. humans are not in the loop.
the end goal: another CLAWDINATOR can spin up a fresh CLAWDINATOR with a single command.

usecase: a CLAWDINATOR (coding agent with messaging capabilities)

- on demand clawdbots are called CLAWDINATOR-{1..n}. 
- CLAWDINATORS must run on a server in hetzner
- infra stack: nix + opentofu
- first we must create 1 POC CLAWDINATOR with working infra. 
- then we create more. 
- CLAWDINATORS must be created declaratively. no interactive setup.
- CLAWDINATORS will connect to our discord server, to start with in #clawdributors-test channel.
- CLAWDINATORS are called CLAWDINATOR-{1..n}. 
- CLAWDINATORS are br00tal. they have a br00tal soul document. its in CLAWDINATOR-SOUL.md. 
- CLAWDINATORS can write and run code for the maintainers.
- CLAWDINATORS can interact with github.
- CLAWDINATORS should use these instructions to get set up with discord. https://github.com/clawdbot/clawdbot/blob/main/docs/discord.md
- CLAWDINATORS should use local Nix examples in sibling repos (ai-stack, nixos-config, gohome) and nix-clawdbot
- CLAWDINATORS should only respond to maintainers. 
- CLAWDINATORS can self-modify themselves.
- CLAWDINATORS can self-deploy themselves after self-modification.
- CLAWDINATORS post a lot of arnie gifs.
- CLAWDINATORS are ephemeral, but have shared memory.
- CLAWDINATORS should store their shared memory in somewhere sensible based on their deployment lifecycle.
- CLAWDINATORS share all memory between instances (hive mind). No per-instance prefix for shared memory.
- For POC, a shared host volume is fine for 1–5 hosts. Use per-instance daily notes like YYYY-MM-DD_INSTANCE.md, but keep key project/architecture memory in single shared files.
- CLAWDINATORS need tokens for GitHub (readonly for now, required).
- GitHub App tokens are short-lived; refresh via a timer if using a GitHub App.
- CLAWDINATORS need an Anthropic API key for Claude models.
- Discord bot tokens should be stored as explicit files via agenix.
- CLAWDINATORS primary tasks are to monitor GitHub issues and GitHub pull requests. 
- CLAWDINATORS can also write code using Codex, in later clawdinator iterations.
- CLAWDINATORS must understand project philosophy, project goals, architecture, and have deep repo knowledge.
- CLAWDINATORS act like maintainers in coding-agent form, with SOTA intelligence.
- CLAWDINATORS use Claude for personality and Codex for coding.

notes on memory for clawdinators:

During Sessions:
Write important things to memory/YYYY-MM-DD.md
Update memory/project.md and memory/architecture.md for durable facts
Update AGENTS.md with lessons learned
Key principle: "Mental notes" don't survive restarts — write it to a file.
Templates live in the clawdbot repo and are synced by automation.
🦐
AGENTS.md has some specific stuff (like how to handle #help, #freshbits channel monitoring, lessons learned from getting roasted for wrong answers 😅), but the structure is the same default templates.
The fancy part is discipline: actually write things down insotead of hoping to remember them next session.

example memory layout:

~/clawd/
├── memory/
│ ├── project.md # Project goals + non-negotiables
│ ├── architecture.md # Architecture decisions + invariants
│ ├── discord.md # Discord-specific stuff
│ ├── whatsapp.md # WhatsApp-specific stuff
│ └── 2026-01-06.md # Daily notes

AGENTS.md should reference specific memory files, e.g. "For Discord context, also read memory/discord.md"

docs:
- docs/PHILOSOPHY.md
- docs/ARCHITECTURE.md
- docs/SHARED_MEMORY.md
- docs/POC.md
- docs/SECRETS.md
- docs/SKILLS_AUDIT.md

nix:
- flake.nix exposes nixosModules.clawdinator (latest upstream nix-clawdbot)
- nix/modules/clawdinator.nix
- nix/examples/clawdinator-host.nix
- nix/examples/flake.nix
- nix/hosts/clawdinator-1.nix

operating mode:
- no manual setup. these machines are created by automation (CLAWDINATORS).
- everything is in repo + agenix. no ad-hoc changes on hosts.
