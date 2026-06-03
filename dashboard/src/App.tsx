import { HashRouter, Routes, Route, Navigate } from 'react-router-dom'
import Shell from './shell/Shell'
import Overview from './routes/Overview'
import Inspect from './routes/Inspect'
import Transform from './routes/Transform'
import Results from './routes/Results'
import CodeActs from './routes/CodeActs'
import Paper from './routes/Paper'

export default function App() {
  return (
    <HashRouter>
      <Shell>
        <Routes>
          <Route path="/" element={<Overview />} />
          <Route path="/inspect" element={<Inspect />} />
          <Route path="/transform" element={<Transform />} />
          <Route path="/results" element={<Results />} />
          <Route path="/codeacts" element={<CodeActs />} />
          <Route path="/paper" element={<Paper />} />
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </Shell>
    </HashRouter>
  )
}
