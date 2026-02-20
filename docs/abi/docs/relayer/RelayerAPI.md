# Relayer CRE API

**Last updated:** 2026-02-20  
**Source:** [creRoutes.ts](../../../../../../apps/relayer/src/api/creRoutes.ts)  
**Context:** [RelayerOverview.md](RelayerOverview.md) | [CREWorkflowIntegration.md](../cre/CREWorkflowIntegration.md)

---

## 1. Overview

The relayer exposes HTTP endpoints for the CRE workflow to fetch session and checkpoint data. All endpoints are under `/cre/`.

---

## 2. Endpoints

### 2.1 GET /cre/sessions

List sessions ready for finalization (`resolveTime <= now`).

**Response:**
```json
{
  "sessions": [
    {
      "sessionId": "0x...",
      "marketId": "0",
      "vaultId": "...",
      "resolveTime": 1234567890,
      "stateHash": "0x...",
      "nonce": "1"
    }
  ]
}
```

**Use:** CRE workflow can call this to know which sessions to process.

---

### 2.2 GET /cre/sessions/:sessionId

Get session payload for **legacy SessionFinalizer** format. Use `/cre/checkpoints/:sessionId` for Nitrolite Yellow (ChannelSettlement).

**Params:** `sessionId` — session identifier (hex)

**Response:**
```json
{
  "sessionId": "0x...",
  "marketId": "0",
  "stateHash": "0x...",
  "participants": ["0x...", "0x..."],
  "payload": "0x...",
  "format": "SessionFinalizer"
}
```

**Errors:** 404 if session not found; 400 if no participants.

---

### 2.3 GET /cre/checkpoints

Get checkpoint metadata for all active sessions.

**Response:**
```json
{
  "checkpoints": [
    {
      "sessionId": "0x...",
      "marketId": "0",
      "checkpoint": { ... },
      "deltas": [ ... ],
      "digest": "0x...",
      "users": ["0x...", "0x..."]
    }
  ]
}
```

---

### 2.4 GET /cre/checkpoints/:sessionId

Get **checkpoint spec** for ChannelSettlement. Returns digest and users so the workflow can collect signatures, then POST to build the full payload.

**Params:** `sessionId` — session identifier (hex)

**Response:**
```json
{
  "sessionId": "0x...",
  "marketId": "0",
  "checkpoint": {
    "marketId": "0",
    "sessionId": "0x...",
    "nonce": "1",
    "validAfter": "0",
    "validBefore": "0",
    "lastTradeAt": 0,
    "stateHash": "0x...",
    "deltasHash": "0x...",
    "riskHash": "0x..."
  },
  "deltas": [
    {
      "user": "0x...",
      "outcomeIndex": 0,
      "sharesDelta": "10",
      "cashDelta": "-1000"
    }
  ],
  "digest": "0x...",
  "users": ["0x...", "0x..."],
  "chainId": 43113,
  "channelSettlementAddress": "0x..."
}
```

**Errors:** 404 if session not found; 400 if no deltas; 503 if `CHANNEL_SETTLEMENT_ADDRESS` not configured.

---

### 2.5 POST /cre/checkpoints/:sessionId

Build full checkpoint payload for ChannelSettlement. Operator signs from `OPERATOR_PRIVATE_KEY`; user signatures come from the request body. Returns `0x03`-prefixed payload for CRE.

**Params:** `sessionId` — session identifier (hex)

**Body:**
```json
{
  "userSigs": {
    "0xUserAddress1": "0x...",
    "0xUserAddress2": "0x..."
  }
}
```

**Response:**
```json
{
  "payload": "0x03...",
  "format": "ChannelSettlement"
}
```

**Errors:** 404 if session not found; 503 if `CHANNEL_SETTLEMENT_ADDRESS` or `OPERATOR_PRIVATE_KEY` missing; 400 if a user signature is missing or build fails.

---

## 3. Typical Workflow Usage

1. **GET** `/cre/checkpoints` or `/cre/sessions` — Find sessions to finalize.
2. **GET** `/cre/checkpoints/:sessionId` — Get digest and users.
3. Collect user signatures (EIP-712 on checkpoint digest).
4. **POST** `/cre/checkpoints/:sessionId` — Send `userSigs`, receive `0x03`-prefixed payload.
5. CRE workflow calls `writeReport(payload)` → Forwarder → CREReceiver.
