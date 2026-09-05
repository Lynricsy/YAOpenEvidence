import { Navigate, Route, Routes } from 'react-router'
import { RequireAuth } from '@/auth/RequireAuth'
import { AppShell } from '@/components/AppShell'
import AskPage from '@/pages/AskPage'
import LoginPage from '@/pages/LoginPage'
import HistoryPage from '@/pages/HistoryPage'
import AccountPage from '@/pages/AccountPage'
import UsersPage from '@/pages/admin/UsersPage'
import LibraryPage from '@/pages/explore/LibraryPage'
import PaperPage from '@/pages/explore/PaperPage'
import KbSearchPage from '@/pages/explore/KbSearchPage'
import LiteratureSearchPage from '@/pages/explore/LiteratureSearchPage'

export default function App() {
  return <Routes>
    <Route path="/login" element={<LoginPage />} />
    <Route element={<RequireAuth />}>
      <Route element={<AppShell />}>
        <Route index element={<AskPage />} />
        <Route path="/a/:answerId" element={<AskPage />} />
        <Route path="/history" element={<HistoryPage />} />
        <Route path="/account" element={<AccountPage />} />
        <Route path="/library" element={<LibraryPage />} />
        <Route path="/library/:key" element={<PaperPage />} />
        <Route path="/kb" element={<KbSearchPage />} />
        <Route path="/search" element={<LiteratureSearchPage />} />
        <Route element={<RequireAuth admin />}>
          <Route path="/admin/users" element={<UsersPage />} />
        </Route>
      </Route>
    </Route>
    <Route path="*" element={<Navigate to="/" replace />} />
  </Routes>
}
