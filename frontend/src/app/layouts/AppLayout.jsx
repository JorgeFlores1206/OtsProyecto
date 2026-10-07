import { Outlet } from 'react-router-dom'

export function AppLayout() {
  return (
    <div>
      <header>
        <h1>Rosa Betania OTs</h1>
      </header>
      <main id="main-content">
        <Outlet />
      </main>
    </div>
  )
}
