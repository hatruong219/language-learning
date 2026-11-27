import { Apple, Smartphone, type LucideIcon } from 'lucide-react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'

const IOS_STEPS = [
  'Mở app bằng Safari hoặc trình duyệt bất kỳ trên iPhone/iPad.',
  'Bấm nút Chia sẻ (biểu tượng hình vuông có mũi tên).',
  'Chọn "Thêm vào MH chính" (Add to Home Screen), rồi bấm "Thêm".',
]

const ANDROID_STEPS = [
  'Mở app bằng Chrome trên Android.',
  'Bấm menu ⋮ ở góc trên bên phải.',
  'Chọn "Cài đặt ứng dụng" hoặc "Thêm vào màn hình chính".',
]

function StepsCard({
  title,
  icon: Icon,
  steps,
}: {
  title: string
  icon: LucideIcon
  steps: readonly string[]
}) {
  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2 text-lg">
          <Icon className="h-5 w-5" />
          {title}
        </CardTitle>
      </CardHeader>
      <CardContent>
        <ol className="list-decimal space-y-2 pl-5 text-sm text-muted-foreground">
          {steps.map((step) => (
            <li key={step}>{step}</li>
          ))}
        </ol>
      </CardContent>
    </Card>
  )
}

export function KotobaInstallGuide() {
  return (
    <div className="grid gap-4 sm:grid-cols-2">
      <StepsCard title="iPhone / iPad (iOS)" icon={Apple} steps={IOS_STEPS} />
      <StepsCard title="Android" icon={Smartphone} steps={ANDROID_STEPS} />
    </div>
  )
}
