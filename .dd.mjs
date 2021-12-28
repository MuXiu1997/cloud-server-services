#!/usr/bin/env zx

const home = os.homedir()
const servicesDir = path.join(home, 'services')
const backupDir = path.join(home, 'backup')

const services = fs
  .readdirSync(servicesDir)
  .filter((d) => !d.startsWith('.') && !['LICENSE', 'README.md'].includes(d))

const service = await question(
  `Choose service: \n${chalk.blueBright.bold(services.join('    '))}\n`,
  {
    choices: services,
  }
)

if (!services.includes(service)) {
  console.log(chalk.red('no such service exists'))
  process.exit(1)
}

const commands = ['up', 'down', 'backup', 'restore']
const command = await question(
  `Choose command: \n${chalk.blueBright.bold(commands.join('    '))}\n`,
  {
    choices: commands,
  }
)

if (!commands.includes(command)) {
  console.log(chalk.red('unsupported commands'))
  process.exit(1)
}

switch (command) {
  case 'up':
    await up()
    break
  case 'down':
    await down()
    break
  case 'backup':
    await backup()
    break
  case 'restore':
    await restore()
    break
}

async function up() {
  await $`docker stack up -c ${path.join(
    servicesDir,
    service,
    'docker-compose.yml'
  )} ${service}`
}

async function down() {
  await $`docker stack down ${service}`
}

async function backup() {
  switch (service) {
    case 'bitwarden':
    case 'nps':
      await $`docker run --rm -v ${service}_data:/data -v ${backupDir}:/backup busybox sh -c 'cd /data && tar cvf /backup/${service}-backup.tar *'`
      break
    default:
      notImplemented()
  }
}

async function restore() {
  switch (service) {
    case 'bitwarden':
    case 'nps':
      await $`docker run --rm -v ${service}_data:/data -v ${backupDir}:/backup busybox sh -c 'tar xvf /backup/${service}-backup.tar -C /data'`
      break
    default:
      notImplemented()
  }
}

function notImplemented() {
  console.log(chalk.red('not implemented'))
}
