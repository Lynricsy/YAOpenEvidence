import {
  createContext,
  useContext,
  useEffect,
  useRef,
  useState,
  type ReactNode,
} from 'react'
export type Theme = 'system' | 'light' | 'dark'
const Context = createContext<{
  theme: Theme
  setTheme: (theme: Theme) => void
  resolved: 'light' | 'dark'
} | null>(null)
export function ThemeProvider({ children }: { children: ReactNode }) {
  const [theme, setTheme] = useState<Theme>(() => {
    const saved = localStorage.getItem('yaoe.theme')
    return saved === 'light' || saved === 'dark' ? saved : 'system'
  })
  const [systemDark, setSystemDark] = useState(
    () => matchMedia('(prefers-color-scheme: dark)').matches,
  )
  const resolved = theme === 'system' ? (systemDark ? 'dark' : 'light') : theme
  useEffect(() => {
    const media = matchMedia('(prefers-color-scheme: dark)')
    const update = () => setSystemDark(media.matches)
    media.addEventListener('change', update)
    return () => media.removeEventListener('change', update)
  }, [])
  const lastResolved = useRef<'light' | 'dark' | null>(null)
  useEffect(() => {
    const apply = () => {
      document.documentElement.classList.toggle('dark', resolved === 'dark')
      document.documentElement.style.colorScheme = resolved
    }
    localStorage.setItem('yaoe.theme', theme)
    // 仅在明暗真正切换时做视图过渡；首帧与同色重渲染直接落地，避免无谓的整页快照。
    const changed =
      lastResolved.current !== null && lastResolved.current !== resolved
    lastResolved.current = resolved
    if (changed && document.startViewTransition)
      document.startViewTransition(apply)
    else apply()
  }, [theme, resolved])
  return (
    <Context.Provider value={{ theme, setTheme, resolved }}>
      {children}
    </Context.Provider>
  )
}
export function useTheme() {
  const value = useContext(Context)
  if (!value) throw new Error('ThemeProvider required')
  return value
}
