import { FeedbackForm } from '@/components/feedback/FeedbackForm'

export const metadata = {
  title: 'Góp ý & Phản hồi',
  description: 'Gửi góp ý để cải thiện trải nghiệm học tiếng Nhật.',
}

export default function FeedbackPage() {
  const siteId = process.env.NEXT_PUBLIC_SITE_ID

  if (!siteId) {
    throw new Error('NEXT_PUBLIC_SITE_ID is not configured.')
  }

  return (
    <div className="container mx-auto px-4 py-10 max-w-3xl">
      <div className="text-center mb-8">
        <h1 className="text-2xl md:text-3xl font-bold mb-2">Góp ý & Phản hồi</h1>
        <p className="text-muted-foreground text-sm md:text-base max-w-xl mx-auto">
          Hãy cho chúng mình biết trải nghiệm của bạn với ứng dụng học tiếng Nhật này.
          Mọi góp ý đều giúp sản phẩm tốt hơn cho cộng đồng.
        </p>
      </div>

      <FeedbackForm siteId={siteId} />
    </div>
  )
}

