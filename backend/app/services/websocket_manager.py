# app/services/websocket_manager.py
from typing import Dict, List
from fastapi import WebSocket

class WebsocketManager:
    def __init__(self):
        self.active_connections: Dict[str, List[WebSocket]] = {}

    async def connect(self, convo_id: str, ws: WebSocket):
        await ws.accept()
        self.active_connections.setdefault(convo_id, []).append(ws)

    def disconnect(self, convo_id: str, ws: WebSocket):
        conns = self.active_connections.get(convo_id, [])
        if ws in conns:
            conns.remove(ws)
        if not conns:
            self.active_connections.pop(convo_id, None)

    async def broadcast(self, convo_id: str, message: dict):
        for ws in self.active_connections.get(convo_id, []):
            await ws.send_json(message)

ws_manager = WebsocketManager()
