# Faucet – Frontend Integration (Testnet Only)

**Last updated:** 2026-03-01  
**ABI:** `Faucet.json`  
**Context:** [DeploymentConfig.md](DeploymentConfig.md) | [Frontend.md](Frontend.md)

---

## 1. Contract Purpose

The **Faucet** provides rate-limited token claims for beta testers on testnet (DeployBetaTestnet). Users can claim mock tokens (MockUSDC, MockDAI, etc.) up to a configured amount per claim, with a cooldown between claims per user per token.

**Production:** Faucet is **not** deployed on mainnet. Use only for Fuji and other testnets.

---

## 2. Frontend Relevance

| Feature | User Role | Use Case |
|---------|-----------|----------|
| Get test tokens | Trader / LP | Claim MockUSDC etc. before deposit |
| Check claim eligibility | All | Show "Claim" vs "Cooldown" state |

---

## 3. Read Methods (Frontend)

| Method | Params | Returns | Use Case |
|--------|--------|---------|----------|
| `canClaim` | `address user`, `address token` | `bool` | Can user claim now? |
| `tokenConfig` | `address token` | `(enabled, amountPerClaim, cooldownSecs)` | Amount and cooldown |
| `lastClaimAt` | `address user`, `address token` | `uint256` | Last claim timestamp |

---

## 4. Write Methods (Frontend)

| Method | Params | When Called |
|--------|--------|-------------|
| `claim` | `address token` | User requests tokens (rate-limited) |

**Pre-requisites:** `canClaim(user, token) == true`. Token must be enabled and cooldown elapsed.

---

## 5. Events

| Event | Indexed | Use Case |
|-------|---------|----------|
| `Claimed` | user, token | Confirm claim; refresh balance |
| `TokenConfigured` | token | Admin config change |

---

## 6. Errors

| Error | User Message |
|-------|--------------|
| `InvalidState` | Cannot claim: token disabled or cooldown not elapsed |
| `InvalidAmount` | Faucet balance too low |

---

## 7. Integration Notes

- **DeployBetaTestnet tokens:** MockUSDC, MockDAI, MockUSDT, MockEURC, MockAVAX, MockIDRX — see [DeploymentConfig.md](DeploymentConfig.md)
- **Flow:** User connects wallet → Check `canClaim(user, MOCK_USDC)` → If true, show "Claim" button → `claim(MOCK_USDC)` → Approve + deposit to MultiAssetVault
- **Cooldown:** Read `tokenConfig(token).cooldownSecs`; show countdown until next claim

---

## 8. References

- [DeploymentConfig.md](DeploymentConfig.md) — Faucet and mock token addresses
- [MultiAssetVault.md](MultiAssetVault.md) — Deposit after claim
