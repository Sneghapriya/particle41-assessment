from fastapi import FastAPI, Request
from datetime import datetime
import uvicorn

app = FastAPI()

@app.get("/")
async def root(request: Request):
    return {
        "timestamp": datetime.utcnow().isoformat(),
        "ip": request.client.host
    }

# Run Uvicorn when script is executed
if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8080)