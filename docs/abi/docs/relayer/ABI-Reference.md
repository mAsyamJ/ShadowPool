# ABI Reference for Relayer Integration

Key contracts and entrypoints for Nitrolite Yellow checkpoint flow and CRE integration.

---

## Relayer Target: ChannelSettlement

**DeployBetaTestnet:** `0xFA5D0e64B0B21374690345d4A88a9748C7E22182`

The relayer submits Nitrolite Yellow checkpoints to `ChannelSettlement`. Required functions:

- `submitCheckpointFromPayload(bytes calldata payload)` — CRE workflow sends `0x03` report
- Checkpoint payload: `(marketId, sessionId, nonce, stateHash, deltasHash)` + `Delta[]`
- Delta: `(user, outcomeIndex, sharesDelta, cashDelta)`

Set in `apps/relayer/.env`:
- `CHANNEL_SETTLEMENT_ADDRESS=0xFA5D0e64B0B21374690345d4A88a9748C7E22182`
- `OPERATOR_PRIVATE_KEY` (must match `OPERATOR`)

---

## CRE Integration Entrypoints

| Contract | Address (Beta) | Role |
|----------|----------------|------|
| **CREReceiver** | 0x51c0680d8E9fFE2A2f6CC65e598280D617D6cAb7 | Receives CRE outcome (0x01) and session (0x03) reports |
| **CREPublishReceiver** | 0x3AA7E5A28A72Df248806397Ea16C03fB10c46830 | Receives CRE publish-from-draft reports |
| **MarketFactory** | 0x2f70602034854C14CBfD1F94C713f833d344d748 | createFromDraft (called via CREPublishReceiver) |

ABIs: `out/ChannelSettlement.sol/ChannelSettlement.json`, `out/CREReceiver.sol/CREReceiver.json`, etc.
