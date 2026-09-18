const js = require('@eslint/js');
const ts = require('typescript-eslint');
const globals = require('globals');

module.exports = ts.config(
  { ignores: ['build/**', '**/node_modules/**'] },
  js.configs.recommended,
  ...ts.configs.recommended,
  { languageOptions: { globals: globals.node } },
  { files: ['**/*.js'], rules: { '@typescript-eslint/no-require-imports': 'off' } },
  {
    files: ['src/**/*.ts'],
    rules: {
      '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
      '@typescript-eslint/no-empty-function': 'off',
    },
  },
);
