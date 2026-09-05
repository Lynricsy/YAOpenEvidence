import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { QueryClientProvider } from '@tanstack/react-query'
import { BrowserRouter } from 'react-router'
import { Toaster } from '@/components/ui/sonner'
import { queryClient } from '@/api/queries'
import { AuthProvider } from '@/auth/store'
import { ThemeProvider } from '@/lib/theme'
import { MotionProvider } from '@/lib/motion'
import { TooltipProvider } from '@/components/ui/tooltip'
import '@fontsource-variable/inter'
import '@fontsource-variable/noto-serif-sc'
import './index.css'
import App from './App.tsx'

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <QueryClientProvider client={queryClient}>
      <ThemeProvider>
        <MotionProvider>
          <TooltipProvider>
            <AuthProvider>
              <BrowserRouter>
                <App />
              </BrowserRouter>
              <Toaster richColors position="top-center" />
            </AuthProvider>
          </TooltipProvider>
        </MotionProvider>
      </ThemeProvider>
    </QueryClientProvider>
  </StrictMode>,
)
