import { Route, Routes } from 'react-router'
import { RequireAuth } from '@/auth/RequireAuth'
import { AppShell } from '@/components/AppShell'
import AskPage from '@/pages/AskPage'
import LoginPage from '@/pages/LoginPage'
import HistoryPage from '@/pages/HistoryPage'

export default function App() {
  return <Routes>
    <Route path="/login" element={<LoginPage />} />
    <Route element={<RequireAuth />}>
      <Route element={<AppShell />}>
        <Route index element={<AskPage />} />
        <Route path="/a/:answerId" element={<AskPage />} />
        <Route path="/history" element={<HistoryPage />} />
      </Route>
    </Route>
    <Route path="*" element={<RequireAuth />} />
  </Routes>
}
