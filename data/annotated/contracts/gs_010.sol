
/**
 * @title CL gauge accepts unverified pools, allowing malicious pool to brick distribution
 * @notice VULNERABLE CONTRACT - Gold Standard Benchmark Item gs_010
 * @dev Source: CODE4RENA - 2025-10-hybra-finance
 *
 * VULNERABILITY INFORMATION:
 * - Type: access_control
 * - Severity: MEDIUM
 * - Finding ID: M-09
 *
 * DESCRIPTION:
 * `GaugeManager._createGauge()` for CL pools (`_gaugeType == 1`) skips factory
 * verification, allowing malicious pools to revert in `updateRewardsGrowthGlobal()`,
 * bricking emissions.
 *
 * VULNERABLE FUNCTIONS:
 * - _createGauge()
 * - createGauge()
 *
 * VULNERABLE LINES:
 * - Lines: 165, 166, 167, 168, 169, 170, 171, 172, 173, 174... (+20 more)
 *
 * ATTACK SCENARIO:
 * A test creates a malicious pool that reverts, votes for it, and `distributeAll()
 *
 * RECOMMENDED FIX:
 * Require `_pool` to be from the trusted CL factory; restrict gauge creation to
 * governance. Status: Unmitigated.
 */

// Full file content could not be retrieved from GitHub raw (access issue); using vulnerable code snippet from report: [L165-189, 185-189, 197-201] - _createGauge skips verification for type 1.