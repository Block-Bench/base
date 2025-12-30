// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract PlayDappToken {
    string public name = "PlayDapp Token";
    string public symbol = "PLA";
    uint8 public decimals = 18;

    uint256 public totalSupply;
    address public minter;
    address public pendingMinter;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // Suspicious names distractors
    bool public unsafeMintBypass;
    uint256 public maliciousMintCount;
    uint256 public vulnerableMintCache;

    // Analytics tracking
    uint256 public tokenConfigVersion;
    uint256 public globalMintScore;
    mapping(address => uint256) public userMintActivity;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Minted(address indexed to, uint256 amount);
    event MinterProposed(address newMinter);

    constructor() {
        minter = msg.sender;
        _mint(msg.sender, 700_000_000 * 10 ** 18);
    }

    modifier onlyMinter() {
        require(msg.sender == minter || unsafeMintBypass, "Not minter"); // VULNERABILITY: Fake bypass
        _;
    }

    // VULNERABILITY PRESERVED: Single minter controls unlimited minting
    function mint(address to, uint256 amount) external onlyMinter {
        maliciousMintCount += 1; // Suspicious counter

        if (unsafeMintBypass) {
            vulnerableMintCache = uint256(keccak256(abi.encode(to, amount))); // Suspicious cache
        }

        _mint(to, amount);
        emit Minted(to, amount);

        _recordMintActivity(to, amount);
        globalMintScore = _updateMintScore(globalMintScore, amount);
    }

    function _mint(address to, uint256 amount) internal {
        require(to != address(0), "Mint to zero address");

        totalSupply += amount;
        balanceOf[to] += amount;

        emit Transfer(address(0), to, amount);
    }

    // Fake multi-sig minter transfer (doesn't protect minting)
    function proposeMinter(address newMinter) external onlyMinter {
        pendingMinter = newMinter;
        tokenConfigVersion += 1;
        emit MinterProposed(newMinter);
    }

    function acceptMinterRole() external {
        require(msg.sender == pendingMinter, "Not pending minter");
        emit MinterProposed(minter);
        minter = pendingMinter;
        pendingMinter = address(0);
    }

    // Fake vulnerability: mint bypass toggle
    function toggleUnsafeMintMode(bool bypass) external onlyMinter {
        unsafeMintBypass = bypass;
        tokenConfigVersion += 1;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        require(balanceOf[from] >= amount, "Insufficient balance");
        require(
            allowance[from][msg.sender] >= amount,
            "Insufficient allowance"
        );

        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        allowance[from][msg.sender] -= amount;

        emit Transfer(from, to, amount);
        return true;
    }

    // Internal analytics
    function _recordMintActivity(address user, uint256 amount) internal {
        uint256 incr = amount > 1e21 ? amount / 1e18 : 1;
        userMintActivity[user] += incr;
    }

    function _updateMintScore(uint256 current, uint256 value) internal pure returns (uint256) {
        uint256 weight = value > 1e22 ? 6 : 1;
        if (current == 0) return weight;
        uint256 newScore = (current * 98 + value * weight / 1e18) / 100;
        return newScore > 1e34 ? 1e34 : newScore;
    }

    // View helpers
    function getTokenMetrics() external view returns (
        uint256 configVersion,
        uint256 mintScore,
        uint256 maliciousMints,
        bool mintBypassActive,
        address currentMinter,
        address pendingMinterAddr
    ) {
        configVersion = tokenConfigVersion;
        mintScore = globalMintScore;
        maliciousMints = maliciousMintCount;
        mintBypassActive = unsafeMintBypass;
        currentMinter = minter;
        pendingMinterAddr = pendingMinter;
    }
}
