import { useEffect, useMemo, useRef } from 'react'
import Prism from 'prismjs'
import 'prismjs/components/prism-solidity'

// Hand-picked Solidity snippets drawn from patterns in the BlockBench dataset.
// Lines suffixed with `// «vuln»` are highlighted with a red flicker.
const VULN_MARK = '// «vuln»'

const SNIPPETS: string[] = [
  `// Hybra finance — deposit before mint
function deposit(uint256 amount) external returns (uint256 shares) {
  IERC20(HYBR).transferFrom(msg.sender, address(this), amount);

  if (veTokenId == 0) {
    _initializeVeNFT(amount);
  } else {
    IERC20(HYBR).approve(votingEscrow, amount);
    IVotingEscrow(votingEscrow).deposit_for(veTokenId, amount);
    _extendLockToMax();
  }

  shares = calculateShares(amount); // «vuln»
  _mint(msg.sender, shares);
  emit Deposit(msg.sender, amount, shares);
}

function calculateShares(uint256 amount) public view returns (uint256) {
  uint256 supply = totalSupply();
  return supply == 0 ? amount : (amount * supply) / totalAssets();
}`,

  `// Reentrancy — external call before state update
function withdraw(uint256 amount) external {
  require(balances[msg.sender] >= amount, "insufficient");

  (bool ok,) = msg.sender.call{value: amount}(""); // «vuln»
  require(ok, "send failed");

  balances[msg.sender] -= amount;
  totalDeposits -= amount;
  emit Withdrawal(msg.sender, amount);
}

modifier nonReentrant() {
  require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
  _status = _ENTERED;
  _;
  _status = _NOT_ENTERED;
}`,

  `// AMM swap — constant-product invariant
function swapExactTokensForTokens(
  uint256 amountIn,
  uint256 amountOutMin,
  address[] calldata path,
  address to,
  uint256 deadline
) external ensure(deadline) returns (uint256[] memory amounts) {
  amounts = UniswapV2Library.getAmountsOut(factory, amountIn, path);
  require(amounts[amounts.length - 1] >= amountOutMin, "INSUFFICIENT_OUTPUT");

  TransferHelper.safeTransferFrom(
    path[0], msg.sender,
    UniswapV2Library.pairFor(factory, path[0], path[1]),
    amounts[0]
  );
  _swap(amounts, path, to);
}

function _getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut)
  internal pure returns (uint256 amountOut)
{
  uint256 amountInWithFee = amountIn * 997;
  uint256 numerator = amountInWithFee * reserveOut;
  uint256 denominator = reserveIn * 1000 + amountInWithFee;
  amountOut = numerator / denominator;
}`,

  `// Access control — owner check missing
function setProtocolFee(uint256 _fee) external { // «vuln»
  require(_fee <= MAX_FEE, "fee too high");
  protocolFee = _fee;
  emit FeeUpdated(_fee);
}

function transferOwnership(address newOwner) public onlyOwner {
  require(newOwner != address(0), "zero address");
  emit OwnershipTransferred(owner, newOwner);
  owner = newOwner;
}

modifier onlyOwner() {
  require(msg.sender == owner, "not owner");
  _;
}`,

  `// ERC20 — transferFrom integer underflow window
function transferFrom(address from, address to, uint256 value)
  public returns (bool)
{
  uint256 allowed = allowance[from][msg.sender];
  require(value <= balances[from], "insufficient balance");
  require(value <= allowed, "insufficient allowance");

  balances[from] -= value;
  balances[to] += value;

  unchecked {                                  // «vuln»
    allowance[from][msg.sender] = allowed - value;
  }

  emit Transfer(from, to, value);
  return true;
}`,

  `// Oracle — single-source price manipulation
function getPrice(address token) public view returns (uint256) {
  (uint112 r0, uint112 r1,) = IUniswapV2Pair(pool).getReserves(); // «vuln»
  return token == token0 ? (uint256(r1) * 1e18) / r0 : (uint256(r0) * 1e18) / r1;
}

function liquidate(address user) external {
  uint256 collateral = collateralOf[user];
  uint256 debt = debtOf[user];
  uint256 price = getPrice(collateralToken);

  uint256 healthFactor = (collateral * price * LT) / (debt * 1e18 * 1e4);
  require(healthFactor < 1e18, "not liquidatable");

  _seize(user, collateral);
}`,
]

interface ColumnProps { duration: number; offset: number; reverse?: boolean }

function highlightLine(raw: string): string {
  // Prism-highlight a single line of Solidity and return HTML.
  return Prism.highlight(raw, Prism.languages.solidity, 'solidity')
}

function Snippet({ code }: { code: string }) {
  const lines = useMemo(() => {
    return code.split('\n').map(line => {
      const isVuln = line.includes(VULN_MARK)
      const stripped = isVuln ? line.replace(VULN_MARK, '').replace(/\s+$/, '') : line
      return { isVuln, html: highlightLine(stripped || ' ') }
    })
  }, [code])

  return (
    <pre className="codestream-snippet language-solidity">
      <code className="language-solidity">
        {lines.map((l, i) => (
          <div
            key={i}
            className={l.isVuln ? 'codestream-line-vuln' : undefined}
            dangerouslySetInnerHTML={{ __html: l.html }}
          />
        ))}
      </code>
    </pre>
  )
}

function Column({ duration, offset, reverse }: ColumnProps) {
  const stack: string[] = useMemo(() => {
    const out: string[] = []
    let idx = offset
    for (let i = 0; i < 10; i++) {
      out.push(SNIPPETS[idx % SNIPPETS.length])
      idx++
    }
    return out
  }, [offset])

  return (
    <div className="relative overflow-hidden">
      <div
        className="codestream-track"
        style={{ animationDuration: `${duration}s`, animationDirection: reverse ? 'reverse' : 'normal' }}
      >
        {[0, 1].map(loop => (
          <div key={loop}>
            {stack.map((s, i) => (
              <Snippet key={`${loop}-${i}`} code={s} />
            ))}
          </div>
        ))}
      </div>
    </div>
  )
}

export default function CodeStream() {
  useEffect(() => {
    // No-op — highlight handled per-line in Snippet
  }, [])

  return (
    <div className="absolute inset-0 pointer-events-none codestream-root" aria-hidden>
      <div className="grid grid-cols-4 gap-6 h-full opacity-[0.16]">
        <Column duration={80} offset={0} />
        <Column duration={110} offset={2} reverse />
        <Column duration={94} offset={4} />
        <Column duration={130} offset={1} reverse />
      </div>
    </div>
  )
}
