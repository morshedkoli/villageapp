import { defineConfig, globalIgnores } from "eslint/config";
import nextVitals from "eslint-config-next/core-web-vitals";
import nextTs from "eslint-config-next/typescript";

const eslintConfig = defineConfig([
  ...nextVitals,
  ...nextTs,
  {
    rules: {
      "@next/next/no-img-element": "off",
    },
  },
  // Override default ignores of eslint-config-next.
  globalIgnores([
    // Default ignores of eslint-config-next:
    ".next/**",
    "out/**",
    "build/**",
    "next-env.d.ts",
    ".firebase/**",
    ".agents/**",
    "villageapp/**",
    "scripts/**",
    // Cloud Functions are CommonJS on the Node 20 runtime, not Next.js
    // sources. They have their own package.json and are deployed separately.
    "functions/**",
  ]),
]);

export default eslintConfig;
