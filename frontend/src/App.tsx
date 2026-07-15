import { useEffect, useState } from "react";

interface StatusResponse {
  status: string;
  system: string;
}

const API = import.meta.env.VITE_API_URL;
console.log("API URL:", API);

function App() {
  const [status, setStatus] = useState("Loading...");
  const [system, setSystem] = useState("");
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function loadStatus() {
      try {
        const response = await fetch(`api/status`);

        if (!response.ok) {
          throw new Error("Backend unavailable");
        }

        const data: StatusResponse = await response.json();

        setStatus(data.status);
        setSystem(data.system);
      } catch (error) {
        console.error("Failed to connect to backend:", error);
        setStatus("Offline");
        setSystem("Unable to reach backend");
      } finally {
        setLoading(false);
      }
    }

    loadStatus();
  }, []);

  return (
    <main
      style={{
        maxWidth: "600px",
        margin: "40px auto",
        fontFamily: "Arial, sans-serif",
        textAlign: "center",
      }}
    >
      <h1>Customer Service System</h1>

      {loading ? (
        <p>Checking backend connection...</p>
      ) : (
        <>
          <p>
            <strong>System:</strong> {system}
          </p>
          <p>
            <strong>Backend Status:</strong> {status}
          </p>
        </>
      )}
    </main>
  );
}

export default App;