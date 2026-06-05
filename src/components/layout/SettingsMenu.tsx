'use client'

import { useEffect, useRef, useState } from 'react'
import { useTheme } from 'next-themes'
import Link from 'next/link'
import { Settings, Sun, Moon, Monitor, MessageCircle, User, ExternalLink } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { cn } from '@/lib/utils'

type Theme = 'light' | 'dark' | 'system'

const THEME_OPTIONS: { value: Theme; label: string; icon: React.ElementType }[] = [
  { value: 'light', label: 'Sáng', icon: Sun },
  { value: 'dark', label: 'Tối', icon: Moon },
  { value: 'system', label: 'Hệ thống', icon: Monitor },
]

export function SettingsMenu() {
  const [open, setOpen] = useState(false)
  const { theme, setTheme, resolvedTheme } = useTheme()
  const [mounted, setMounted] = useState(false)
  const ref = useRef<HTMLDivElement>(null)

  useEffect(() => {
    setMounted(true)
  }, [])

  useEffect(() => {
    if (!open) return
    function handleClickOutside(e: MouseEvent) {
      if (ref.current && !ref.current.contains(e.target as Node)) {
        setOpen(false)
      }
    }
    document.addEventListener('mousedown', handleClickOutside)
    return () => document.removeEventListener('mousedown', handleClickOutside)
  }, [open])

  const CurrentIcon = mounted ? (resolvedTheme === 'dark' ? Moon : Sun) : Settings

  return (
    <div ref={ref} className="relative">
      <Button
        variant="ghost"
        size="icon"
        aria-label="Cài đặt"
        onClick={() => setOpen((v) => !v)}
        className={cn(open && 'bg-accent')}
      >
        <CurrentIcon className="h-5 w-5" />
      </Button>

      {open && (
        <div className="absolute right-0 top-full mt-2 w-56 rounded-xl border border-border bg-popover shadow-lg z-50 overflow-hidden">
          <div className="px-3 pt-3 pb-2">
            <p className="text-xs font-semibold text-muted-foreground uppercase tracking-wide mb-2">
              Giao diện
            </p>
            <div className="flex gap-1">
              {THEME_OPTIONS.map(({ value, label, icon: Icon }) => (
                <button
                  key={value}
                  onClick={() => setTheme(value)}
                  className={cn(
                    'flex-1 flex flex-col items-center gap-1 py-2 rounded-lg text-xs font-medium transition-colors',
                    mounted && theme === value
                      ? 'bg-primary text-primary-foreground'
                      : 'text-muted-foreground hover:bg-accent hover:text-accent-foreground',
                  )}
                >
                  <Icon className="h-4 w-4" />
                  {label}
                </button>
              ))}
            </div>
          </div>

          <div className="h-px bg-border mx-3" />

          <div className="p-2">
            <Link
              href="/feedback"
              onClick={() => setOpen(false)}
              className="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium text-muted-foreground hover:bg-accent hover:text-accent-foreground transition-colors"
            >
              <MessageCircle className="h-4 w-4 shrink-0" />
              Góp ý
            </Link>

            <a
              href="https://www.truongha.com/"
              target="_blank"
              rel="noopener noreferrer"
              onClick={() => setOpen(false)}
              className="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium text-muted-foreground hover:bg-accent hover:text-accent-foreground transition-colors"
            >
              <User className="h-4 w-4 shrink-0" />
              <span className="flex-1">About me</span>
              <ExternalLink className="h-3 w-3 opacity-50" />
            </a>
          </div>
        </div>
      )}
    </div>
  )
}
