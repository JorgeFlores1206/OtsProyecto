import { RouterProvider } from 'react-router-dom'
import { AppProviders } from './app/AppProviders.jsx'
import { router } from './app/router.jsx'

export default function App() {
  return (
    <AppProviders>
      <RouterProvider router={router} />
    </AppProviders>
  )
}
