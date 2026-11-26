import { Loader2 } from 'lucide-react'

export default function GlobalLoading() {
    return (
        <div className="flex flex-col items-center justify-center min-h-[calc(100vh-14rem)] bg-background">
            <Loader2 className="h-8 w-8 animate-spin text-primary" />
            <p className="mt-4 text-sm font-medium text-muted-foreground animate-pulse">
                Đang tải dữ liệu...
            </p>
        </div>
    )
}
