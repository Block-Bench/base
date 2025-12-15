import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import LandingPage from './components/LandingPage'
import Explorer from './components/Explorer'
import CodeViewer from './components/CodeViewer'

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<LandingPage />} />
        <Route path="/explorer" element={<Explorer />} />
        <Route path="/sample/:id" element={<CodeViewer />} />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </BrowserRouter>
  )
}

export default App
