import { NavLink } from "react-router-dom";

import {
  FaChartLine,
  FaHome,
  FaProjectDiagram,
  FaBell,
  FaClipboardList,
  FaDatabase,
  FaCog
} from "react-icons/fa";

const menu = [
  {
    name: "Dashboard",
    path: "/dashboard",
    icon: <FaHome />
  },
  {
    name: "Analytics",
    path: "/analytics",
    icon: <FaChartLine />
  },
  {
    name: "Pipeline",
    path: "/pipeline",
    icon: <FaProjectDiagram />
  },
  {
    name: "Alerts",
    path: "/alerts",
    icon: <FaBell />
  },
  {
    name: "Incident Logs",
    path: "/incident-logs",
    icon: <FaClipboardList />
  },
  {
    name: "Dead Letter Queue",
    path: "/dlq",
    icon: <FaDatabase />
  },
  {
    name: "Settings",
    path: "/settings",
    icon: <FaCog />
  }
];

export default function Sidebar() {
  return (
    <aside className="w-72 bg-slate-800 shadow-xl">

      <div className="text-center py-8">

        <h1 className="text-3xl font-bold text-cyan-400">
          IceStream
        </h1>

        <p className="text-gray-400 text-sm">
          Monitoring Dashboard
        </p>

      </div>

      <nav className="px-4">

        {menu.map((item) => (

          <NavLink
            key={item.name}
            to={item.path}
            className={({ isActive }) =>
              `flex items-center gap-4 p-4 rounded-xl mb-3 transition ${
                isActive
                  ? "bg-cyan-600"
                  : "hover:bg-slate-700"
              }`
            }
          >
            {item.icon}

            {item.name}

          </NavLink>

        ))}

      </nav>

    </aside>
  );
}