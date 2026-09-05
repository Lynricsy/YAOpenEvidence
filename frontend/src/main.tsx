import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { QueryClientProvider } from '@tanstack/react-query'
import { BrowserRouter } from 'react-router'
import { Toaster } from '@/components/ui/sonner'
import { queryClient } from '@/api/queries'
import { AuthProvider } from '@/auth/store'
import { ThemeProvider } from '@/lib/theme'
import { TooltipProvider } from '@/components/ui/tooltip'
import './index.css'
import App from './App.tsx'

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <QueryClientProvider client={queryClient}>
      <ThemeProvider><TooltipProvider>
      <AuthProvider>
        <BrowserRouter><App /></BrowserRouter>
        <Toaster richColors position="top-center" />
      </AuthProvider>
      </TooltipProvider></ThemeProvider>
    </QueryClientProvider>
  </StrictMode>,
)
