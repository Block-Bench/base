import { HashRouter, Routes, Route, Navigate } from 'react-router-dom'
import LandingPage from './components/LandingPage'
import Explorer from './components/Explorer'
import CodeViewer from './components/CodeViewer'
import StrategiesPlayground from './components/StrategiesPlayground'

function App() {
  return (
    <HashRouter>
      <Routes>
        <Route path="/" element={<LandingPage />} />
        <Route path="/explorer" element={<Navigate to="/explorer/base" replace />} />
        <Route path="/explorer/:datasetType" element={<Explorer />} />
        <Route path="/sample/:datasetType/:sampleId" element={<CodeViewer />} />
        <Route path="/strategies" element={<StrategiesPlayground />} />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </HashRouter>
  )
}

export default App
