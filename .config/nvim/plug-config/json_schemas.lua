return {
  {
    description = 'JSON schema for NPM package.json files',
    fileMatch = { 'package.json' },
    url = 'https://json.schemastore.org/package.json'
  }, {
    description = 'TypeScript compiler configuration file',
    fileMatch = { 'tsconfig.json', 'tsconfig.*.json' },
    url = 'https://json.schemastore.org/tsconfig'
  }, {
    description = 'Lerna config',
    fileMatch = { 'lerna.json' },
    url = 'https://json.schemastore.org/lerna'
  }, {
    description = 'Babel configuration',
    fileMatch = { '.babelrc.json', '.babelrc', 'babel.config.json' },
    url = 'https://json.schemastore.org/lerna'
  }, {
    description = 'ESLint config',
    fileMatch = { '.eslintrc.json', '.eslintrc' },
    url = 'https://json.schemastore.org/eslintrc'
  }, {
    description = 'Prettier config',
    fileMatch = { '.prettierrc', '.prettierrc.json', 'prettier.config.json' },
    url = 'https://json.schemastore.org/prettierrc'
  }
}
