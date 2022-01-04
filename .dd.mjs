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
      await backupVolume(service, 'data')
      break
    case 'sftpgo':
      await backupVolume(service, 'data')
      await backupVolume(service, 'config')
      break
    default:
      notImplemented()
  }
}

async function restore() {
  switch (service) {
    case 'bitwarden':
    case 'nps':
      await restoreVolume(service, 'data')
      break
    case 'sftpgo':
      await restoreVolume(service, 'data')
      await restoreVolume(service, 'config')
      break
    default:
      notImplemented()
  }
}

async function backupVolume(service, volume) {
  await $`docker run --rm -v ${service}_${volume}:/data -v ${backupDir}:/backup busybox sh -c 'cd /data && tar cvf /backup/${service}-${volume}-backup.tar *'`
}

async function restoreVolume(service, volume) {
  await $`docker run --rm -v ${service}_${volume}:/data -v ${backupDir}:/backup busybox sh -c 'tar xvf /backup/${service}-${volume}-backup.tar -C /data'`
}

function notImplemented() {
  console.log(chalk.red('not implemented'))
}
