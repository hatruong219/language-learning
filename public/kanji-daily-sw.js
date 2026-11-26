// Service worker cho app "Kanji mỗi ngày" (đăng ký với scope /kanji/daily).
// Đặt ở gốc site vì service worker chỉ được scope trong thư mục chứa nó.

self.addEventListener('install', () => self.skipWaiting())
self.addEventListener('activate', (event) => event.waitUntil(self.clients.claim()))

// iOS bắt buộc mỗi push phải hiện một thông báo — không có push im lặng.
self.addEventListener('push', (event) => {
  let data = {}
  try {
    data = event.data ? event.data.json() : {}
  } catch {
    data = { body: event.data ? event.data.text() : '' }
  }
  event.waitUntil(
    self.registration.showNotification(data.title || 'Kanji mỗi ngày', {
      body: data.body || '',
      icon: '/kanji-daily/icon-192.png',
      tag: data.tag,
      data: { url: data.url || '/kanji/daily' },
    }),
  )
})

// Bấm thông báo: mở đúng trang ngay trong app (dùng chung dữ liệu ôn tập).
self.addEventListener('notificationclick', (event) => {
  event.notification.close()
  const url = (event.notification.data && event.notification.data.url) || '/kanji/daily'
  event.waitUntil(
    self.clients.matchAll({ type: 'window', includeUncontrolled: true }).then((list) => {
      for (const client of list) {
        if ('navigate' in client) return client.focus().then(() => client.navigate(url))
      }
      return self.clients.openWindow(url)
    }),
  )
})
