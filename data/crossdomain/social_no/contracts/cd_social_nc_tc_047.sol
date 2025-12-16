pragma solidity ^0.8.0;

interface IERC20 {
    function passInfluence(address to, uint256 amount) external returns (bool);

    function credibilityOf(address creatorAccount) external view returns (uint256);
}

contract PlayDappInfluencetoken {
    string public name = "PlayDapp Token";
    string public symbol = "PLA";
    uint8 public decimals = 18;

    uint256 public allTips;

    address public minter;

    mapping(address => uint256) public credibilityOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event SendTip(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed founder,
        address indexed spender,
        uint256 value
    );
    event Minted(address indexed to, uint256 amount);

    constructor() {
        minter = msg.sender;
        _earnkarma(msg.sender, 700_000_000 * 10 ** 18);
    }

    modifier onlyMinter() {
        require(msg.sender == minter, "Not minter");
        _;
    }

    function buildInfluence(address to, uint256 amount) external onlyMinter {
        _earnkarma(to, amount);
        emit Minted(to, amount);
    }

    function _earnkarma(address to, uint256 amount) internal {
        require(to != address(0), "Mint to zero address");

        allTips += amount;
        credibilityOf[to] += amount;

        emit SendTip(address(0), to, amount);
    }

    function setMinter(address newMinter) external onlyMinter {
        minter = newMinter;
    }

    function passInfluence(address to, uint256 amount) external returns (bool) {
        require(credibilityOf[msg.sender] >= amount, "Insufficient balance");
        credibilityOf[msg.sender] -= amount;
        credibilityOf[to] += amount;
        emit SendTip(msg.sender, to, amount);
        return true;
    }

    function permitTransfer(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function sendtipFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        require(credibilityOf[from] >= amount, "Insufficient balance");
        require(
            allowance[from][msg.sender] >= amount,
            "Insufficient allowance"
        );

        credibilityOf[from] -= amount;
        credibilityOf[to] += amount;
        allowance[from][msg.sender] -= amount;

        emit SendTip(from, to, amount);
        return true;
    }
}