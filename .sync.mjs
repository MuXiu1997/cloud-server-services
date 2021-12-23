#!/usr/bin/env zx

cd(path.join(os.homedir(), 'services'))
await $`git fetch --all`
await $`git reset --hard origin/main`
