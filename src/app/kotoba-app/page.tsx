import { Smartphone } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { KotobaInstallGuide } from '@/components/kotoba/KotobaInstallGuide'

export const metadata = {
  title: 'Kotoba — app học từ vựng',
  description: 'Cài app Kotoba lên màn hình chính để học từ vựng, kanji và ngữ pháp tiếng Nhật.',
}

const NOTES = [
  'Dữ liệu học (tiến độ, từ đã thuộc) được lưu ngay trong máy của bạn, không lưu trên máy chủ.',
  'Nên cài app ra màn hình chính: trên iOS, trình duyệt có thể xoá dữ liệu trang web nếu không mở trong 7 ngày.',
  'Vào Cài đặt trong app để xuất file sao lưu, và nhập lại khi đổi máy hoặc bị mất dữ liệu.',
  'Trên iPhone, app ngoài màn hình chính có bộ nhớ riêng, tách khỏi Safari. Nếu đã học trong Safari trước, hãy xuất file sao lưu ở đó rồi nhập lại sau khi cài.',
  'Đang dùng bản Kotoba cài qua Sideloadly? Xuất tiến độ từ app cũ (Cài đặt → Sao lưu) rồi nhập vào đây.',
  'Luyện nói cần cho phép quyền micro, và cần có kết nối mạng.',
]

export default function KotobaAppPage() {
  return (
    <div className="container mx-auto max-w-3xl space-y-8 px-4 py-10">
      <section className="space-y-4 text-center">
        <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-2xl bg-accent">
          <Smartphone className="h-8 w-8" />
        </div>
        <h1 className="text-3xl font-bold">Kotoba — app học từ vựng</h1>
        <p className="text-muted-foreground">
          Học từ vựng, kanji và ngữ pháp tiếng Nhật ngay trên điện thoại. Cài app lên màn hình chính
          để mở nhanh như app thường.
        </p>
        {/* Thẻ <a> thường: đây là file tĩnh của Flutter, không phải route Next. */}
        <Button asChild size="lg">
          <a href="/kotoba-app/app/index.html">Mở app</a>
        </Button>
      </section>

      <section className="space-y-3">
        <h2 className="text-xl font-semibold">Cài lên màn hình chính</h2>
        <KotobaInstallGuide />
      </section>

      <Card>
        <CardHeader>
          <CardTitle className="text-lg">Lưu ý</CardTitle>
        </CardHeader>
        <CardContent>
          <ul className="list-disc space-y-2 pl-5 text-sm text-muted-foreground">
            {NOTES.map((note) => (
              <li key={note}>{note}</li>
            ))}
          </ul>
        </CardContent>
      </Card>
    </div>
  )
}
