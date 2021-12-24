#!/usr/bin/env zx

const { sshHost, sshUsername } = argv

const DOCKER_SECRET_PREFIX = 'DOCKER_SECRET_'

const keys = Object.keys(process.env).filter((k) =>
  k.startsWith(DOCKER_SECRET_PREFIX)
)

const script = keys
  .map((k) => {
    const secretKey = k.slice(DOCKER_SECRET_PREFIX.length)
    return `docker secret rm ${secretKey}
  echo '${process.env[k]}' | docker secret create ${secretKey} -`
  })
  .join('\n')

await nothrow(
  $`ssh -o StrictHostKeyChecking=no ${sshUsername}@${sshHost} ${script}`
)
