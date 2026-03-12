import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  serverExternalPackages: [
    'tesseract.js',
    'tesseract.js-core',
    'node-fetch',
    'bmp-js',
    'idb-keyval',
    'wasm-feature-detect',
    'zlibjs',
  ],
};

export default nextConfig;
