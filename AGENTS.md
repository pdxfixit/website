# Rules for agents working in this repo

- **Edit `src/`, run `python3 build.py`, commit `src/` and `public/` together.** The deploy runs `python3 build.py
  --check` (`just test`) and refuses a `public/` that `src/` would not build.
- **Land with `just land`**, from your own branch (a worktree): flarepress's shared tool pulls `master` from GitHub
  first, cherry-picks your commits, runs `just test`, and pushes. A push to `master` deploys
  (`.github/workflows/deploy.yml`); check that run before saying a change is live.
