# FeeManager – Frontend Integration

Last updated: 2026-02-20  
ABI: `FeeManager.json`  
Context: [Frontend.md](Frontend.md) | [CurrentSmartContract.md](../CurrentSmartContract.md)

---

## 1. Contract Purpose

`FeeManager` computes fee splits (protocol, LP, creator) on positive cash deltas during checkpoint settlement. It is used by `ChannelSettlement`; frontend reads config for display (e.g., fee percentage).

---

## 2. Frontend Relevance

| Feature | User Role | Use Case |
|--------|-----------|----------|
| Fee display | Trader, LP | `protocolFeeBps`, `lpFeeShareBps`, `creatorFeeShareBps` |
| Fee computation | Dev | `computeFee`, `computeSplit` for previews |

---

## 3. Read Methods (Frontend)

| Method | Params | Returns | Use Case |
|--------|--------|---------|----------|
| `protocolFeeBps` | — | `uint16` | Protocol fee rate (basis points) |
| `lpFeeShareBps` | — | `uint16` | LP share of total fee |
| `creatorFeeShareBps` | — | `uint16` | Creator share of total fee |
| `BPS_DENOMINATOR` | — | `uint16` | 10000 |
| `MAX_PROTOCOL_FEE_BPS` | — | `uint16` | Cap (e.g. 200 = 2%) |
| `computeFee` | `int128 pnlDelta` | `uint256 fee`, `int128 netDelta` | Fee for given PnL |
| `computeSplit` | `int128 pnlDelta` | `protocolFee`, `lpFee`, `creatorFee`, `netDelta` | Split breakdown |
| `owner` | — | `address` | Admin |

---

## 4. Write Methods (Frontend)

None. Setters are admin-only.

---

## 5. Events

| Event | Indexed Params | Use Case |
|-------|----------------|----------|
| `ProtocolFeeBpsUpdated` | — | Policy change |
| `LpFeeShareBpsUpdated` | — | Policy change |
| `CreatorFeeShareBpsUpdated` | — | Policy change |
| `OwnershipTransferred` | `previousOwner`, `newOwner` | Admin |

---

## 6. Errors

| Error | User-Friendly Message |
|-------|------------------------|
| `FeeExceedsCap` | Fee exceeds maximum |
| `InvalidFeeShare` | Invalid fee share |
| `SafeCastOverflowedIntDowncast` | Internal error |
| `SafeCastOverflowedIntToUint` | Internal error |
| `SafeCastOverflowedUintToInt` | Internal error |
| `OwnableUnauthorizedAccount` | Unauthorized |

---

## 7. Integration Notes

- Use `protocolFeeBps` / `lpFeeShareBps` / `creatorFeeShareBps` for fee display.
- `computeSplit` useful for showing estimated fee on profit before checkpoint.
- Not typically a deployment config key for frontend.

---

## 8. References

- [ChannelSettlement.md](ChannelSettlement.md) — Uses FeeManager during checkpoint
- [FeePool.md](FeePool.md) — Protocol fee destination
- [AppFlow.md](AppFlow.md) — Fee flow
