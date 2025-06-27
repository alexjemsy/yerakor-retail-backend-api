// @ts-check

import eslint from '@eslint/js';
import typescriptEsLint from 'typescript-eslint';
import prettierConfig from 'eslint-config-prettier';

export default typescriptEsLint.config(
  {
    // config with just ignores is the replacement for `.eslintignore`
    ignores: [
      '**/node_modules/**',
      '**/dist/**',
      '**/zapatos/**',
      '**/config/**',
      'codegen.js',
      'vitest.config.js',
      'cspell.config.cjs',
      'src/graphql/types.generated.ts',
      '**/devConfig/**',
      '**/zapatos/**',
      '**/dev_config/**',
    ],
  },
  eslint.configs.recommended,
  ...typescriptEsLint.configs.strictTypeChecked,
  ...typescriptEsLint.configs.stylisticTypeChecked,
  {
    languageOptions: {
      parserOptions: {
        project: './tsconfig.eslint.json',
        tsconfigRootDir: import.meta.dirname,
      },
    },
  },
  {
    rules: {
      '@typescript-eslint/no-unsafe-call': 'off',
      '@typescript-eslint/no-unsafe-member-access': 'off',
      '@typescript-eslint/no-non-null-assertion': 'off',
      '@typescript-eslint/restrict-template-expressions': [
        'error',
        {
          allowAny: false,
          allowBoolean: false,
          allowNullish: false,
          allowNumber: true,
          allowRegExp: false,
          allowNever: false,
        },
      ],
    },
  },
  prettierConfig, // should be the last config, other configs should go above this line
);
