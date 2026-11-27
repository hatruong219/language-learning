import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  async redirects() {
    return [
      // Flashcard gộp vào Từ vựng, menu Chủ đề bỏ. Link cũ đã lưu hoặc đã chia
      // sẻ không được trả 404 — chuyển về chỗ tương đương.
      { source: '/flashcard', destination: '/vocabulary/flashcard', permanent: true },
      { source: '/flashcard/:slug', destination: '/vocabulary/flashcard', permanent: true },
      { source: '/decks', destination: '/vocabulary', permanent: true },
      { source: '/decks/:slug', destination: '/vocabulary', permanent: true },
      // App Flutter web là file tĩnh; Next bỏ dấu `/` cuối nên dùng index.html làm URL chuẩn.
      { source: '/kotoba-app/app', destination: '/kotoba-app/app/index.html', permanent: false },
      { source: '/kotoba-app/app/', destination: '/kotoba-app/app/index.html', permanent: false },
    ]
  },
};

export default nextConfig;
