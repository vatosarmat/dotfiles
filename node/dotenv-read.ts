const { existsSync } = require('node:fs')

if (process.argv.length <= 2) {
  console.error('file path and variable names expected')
  process.exit(1)
}

let filePath
let variables
if (existsSync(process.argv[2])) {
  filePath = process.argv[2]
  variables = process.argv.slice(3)
} else {
  filePath = '.env'
  variables = process.argv.slice(2)
}

const env = require('dotenv').config({ path: filePath }).parsed

if (!env) {
  console.error(`${filePath} not found`)
  process.exit(1)
}

process.stdout.write(
  variables
    .map(item => {
      if (!env[item]) {
        console.error(`${item} - no such variable`)
        process.exit(1)
      }
      return env[item]
    })
    .join(' ')
)
