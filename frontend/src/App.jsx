import { useEffect, useState } from "react";

function App() {

  const [tasks, setTasks] = useState([]);

  useEffect(() => {

    fetch("/api/tasks")
      .then(response => response.json())
      .then(data => setTasks(data))
      .catch(error => console.error(error));

  }, []);

  return (
    <div style={{
      maxWidth: "800px",
      margin: "50px auto",
      fontFamily: "Arial"
    }}>

      <h1>TaskFlow</h1>

      <p>Dockerized React + FastAPI + PostgreSQL application</p>

      <h2>Tasks</h2>

      {tasks.map(task => (
        <div
          key={task.id}
          style={{
            padding: "15px",
            margin: "10px 0",
            border: "1px solid #ddd",
            borderRadius: "5px"
          }}
        >

          <strong>{task.title}</strong>

          <p>
            Status: {task.status}
          </p>

        </div>
      ))}

    </div>
  );
}

export default App;
