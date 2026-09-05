import { Route, Routes } from 'react-router'
import { RequireAuth } from '@/auth/RequireAuth'
import { AppShell } from '@/components/AppShell'
import AskPage from '@/pages/AskPage'
import LoginPage from '@/pages/LoginPage'
import HistoryPage from '@/pages/HistoryPage'
import AccountPage from '@/pages/AccountPage'
import UsersPage from '@/pages/admin/UsersPage'

export default function App() {
  return <Routes>
    <Route path="/login" element={<LoginPage />} />
    <Route element={<RequireAuth />}>
      <Route element={<AppShell />}>
        <Route index element={<AskPage />} />
        <Route path="/a/:answerId" element={<AskPage />} />
        <Route path="/history" element={<HistoryPage />} />
        <Route path="/account" element={<AccountPage />} />
        <Route element={<RequireAuth admin />}>
          <Route path="/admin/users" element={<UsersPage />} />
        </Route>
      </Route>
    </Route>
    <Route path="*" element={<RequireAuth />} />
  </Routes>
}
