import { FaBell, FaUserCircle } from "react-icons/fa";

export default function Navbar() {
  return (
    <header className="h-20 bg-slate-800 flex items-center justify-between px-8 shadow-lg">

      <div>

        <h2 className="text-2xl font-bold">

          IceStream Dashboard

        </h2>

        <p className="text-gray-400 text-sm">

          Real-Time Lakehouse Monitoring

        </p>

      </div>

      <div className="flex items-center gap-6">

        <FaBell
          size={24}
          className="cursor-pointer hover:text-cyan-400"
        />

        <div className="flex items-center gap-3">

          <FaUserCircle
            size={40}
            className="text-cyan-400"
          />

          <div>

            <h3 className="font-semibold">

              Mehul Sorte

            </h3>

            <p className="text-gray-400 text-sm">

              Frontend Developer

            </p>

          </div>

        </div>

      </div>

    </header>
  );
}