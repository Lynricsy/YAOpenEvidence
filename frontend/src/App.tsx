import { Route, Routes } from 'react-router'
import { RequireAuth } from '@/auth/RequireAuth'
import { AppShell } from '@/components/AppShell'
import { EmptyState } from '@/components/EmptyState'
import LoginPage from '@/pages/LoginPage'

export default function App() {
  return <Routes><Route path="/login" element={<LoginPage />} /><Route element={<RequireAuth />}><Route element={<AppShell />}><Route index element={<EmptyState title="循证医学文献问答" />} /></Route></Route><Route path="*" element={<RequireAuth />} /></Routes>
}
