import { createBrowserRouter } from 'react-router-dom'
import { AppLayout } from './layouts/AppLayout.jsx'

const homePlaceholder = (
  <section aria-labelledby="home-title">
    <h2 id="home-title">Órdenes de trabajo</h2>
    <p>La operación funcional se incorporará por historias de usuario.</p>
  </section>
)

const notFoundPlaceholder = (
  <section aria-labelledby="not-found-title">
    <h2 id="not-found-title">Página no encontrada</h2>
    <p>La ruta solicitada no existe.</p>
  </section>
)

export const router = createBrowserRouter([
  {
    path: '/',
    element: <AppLayout />,
    children: [
      { index: true, element: homePlaceholder },
      { path: '*', element: notFoundPlaceholder },
    ],
  },
])
