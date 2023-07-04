module.exports = {
  arrowParens: 'always',
  printWidth: 100,
  singleQuote: true,
  trailingComma: 'all',
  useTabs: false,
  overrides: [
    {
      files: 'src/**/*.sol',
      options: {
        printWidth: 100,
        tabWidth: 4,
        useTabs: false,
        singleQuote: false,
        bracketSpacing: false,
        explicitTypes: 'always',
      },
    },
  ],
};
