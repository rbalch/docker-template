import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import mcp

debug = bool(os.getenv("DEBUG", False))

app = FastAPI(
    title='MCP Server',
    version='1.0',
    description='MCP Server with FastAPI',
)

# Set all CORS enabled origins
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["*"],
)

# Register MCP routes with FastAPI
mcp.setup_fastapi(app)

# Your existing endpoints
@app.get('/')
async def home():
    return {'message': 'Home'}

# MCP-specific endpoint for status
@app.get('/mcp/status')
async def mcp_status():
    return {'status': 'running', 'version': mcp.__version__}

if debug:
    import debugpy
    debugpy.listen(("0.0.0.0", 5678))
    print("VS Code debugger is ready to be attached, press F5 in VS Code...")

if __name__ == '__main__':
    import uvicorn
    uvicorn.run('server:app', host='0.0.0.0', port=8000, reload=True)