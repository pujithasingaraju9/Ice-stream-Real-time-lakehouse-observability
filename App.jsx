import { Routes, Route, Navigate } from "react-router-dom";

import MainLayout from "./layouts/MainLayout";

import Dashboard from "./pages/Dashboard";
import Analytics from "./pages/Analytics";
import Pipeline from "./pages/Pipeline";
import Alerts from "./pages/Alerts";
import IncidentLogs from "./pages/IncidentLogs";
import DLQ from "./pages/DLQ";
import Settings from "./pages/Settings";

export default function App() {
  return (
    <Routes>
      <Route element={<MainLayout />}>
        <Route path="/" element={<Navigate to="/dashboard" />} />
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/analytics" element={<Analytics />} />
        <Route path="/pipeline" element={<Pipeline />} />
        <Route path="/alerts" element={<Alerts />} />
        <Route path="/incident-logs" element={<IncidentLogs />} />
        <Route path="/dlq" element={<DLQ />} />
        <Route path="/settings" element={<Settings />} />
      </Route>
    </Routes>
  );
}