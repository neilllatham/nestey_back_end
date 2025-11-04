const API_BASE = "http://localhost:3001/api/timeoff";

export async function getTimeOffRequests() {
  const res = await fetch(API_BASE);
  if (!res.ok) throw new Error("Failed to fetch time-off data");
  return res.json();
}

export async function createTimeOffRequest(requestData) {
  const res = await fetch(API_BASE, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(requestData),
  });
  if (!res.ok) throw new Error("Failed to create time-off request");
  return res.json();
}

export async function updateTimeOffStatus(id, status) {
  const res = await fetch(`${API_BASE}/${id}`, {
    method: "PUT",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ status }),
  });
  if (!res.ok) throw new Error("Failed to update time-off status");
  return res.json();
}
