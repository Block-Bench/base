# Rebuttal for ms_tc_019 (Qubit Bridge)

## Summary
**Agree** - We accept the PREREQ overuse concerns and improved ROOT_CAUSE rationale.

## Issue-by-Issue Response

### Issue 2.1 - CA5 (deposit forwarding) misclassified as PREREQ
**Agree - UPDATED**
Forwarding the call is correct bridge behavior. The vulnerability exists inside QBridgeHandler.deposit. Changed to BENIGN.

### Issue 2.2 - CA7 (resourceID mapping) misclassified as PREREQ
**Agree - UPDATED**
The existence of a mapping is not a prerequisite. The flaw is failure to validate lookup results. Changed to BENIGN.

### Issue 2.3 - CA8 (unused whitelist) misclassified as PREREQ
**Agree - UPDATED**
This mapping is unused. Dead state cannot be a prerequisite. Changed to BENIGN.

### Issue 2.4 - CA9 (mapping read) over-labeled as PREREQ
**Agree - UPDATED**
Reading from a mapping is mechanical. The vulnerability is the absence of validation after the read. Changed to BENIGN.

### Issue 2.5 - CA11 ROOT_CAUSE rationale
**Agree - UPDATED**
Improved rationale to focus on missing validation invariant rather than EVM behavior specifics.

### Issue 2.6 - CA12 SECONDARY_VULN
**Kept as-is**
Clarified rationale to state this is an independent misconfiguration risk, not an exploit prerequisite.

### Issue 1.1 - Metadata overstates EVM behavior
**Noted**
The exploit relies on missing validation + event-based minting, not guaranteed EVM success.

### Issue 1.2 - Root cause scope leak
**Noted**
Root cause should stop at local invariant violation enabling false deposit events.

## Changes Made

| Code Act | Before | After |
|----------|--------|-------|
| CA5 (deposit forward) | PREREQ | BENIGN |
| CA7 (mapping) | PREREQ | BENIGN |
| CA8 (unused whitelist) | PREREQ | BENIGN |
| CA9 (mapping read) | PREREQ | BENIGN |
| CA11 rationale | EVM-focused | Invariant-focused |

## Final Classification

- **ROOT_CAUSE (1)**: CA11 - missing validation before external call (line 67)
- **SECONDARY_VULN (1)**: CA12 - setResource lacks access control
- **PREREQ (0)**: None
- **BENIGN (10)**: All other code acts
