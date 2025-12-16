pragma solidity ^0.8.0;

interface IERC20 {
    function assignCredit(address to, uint256 amount) external returns (bool);

    function remainingbenefitOf(address memberRecord) external view returns (uint256);
}

contract PlayDappMedicalcredit {
    string public name = "PlayDapp Token";
    string public symbol = "PLA";
    uint8 public decimals = 18;

    uint256 public fundTotal;

    address public minter;

    mapping(address => uint256) public remainingbenefitOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event TransferBenefit(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed coordinator,
        address indexed spender,
        uint256 value
    );
    event Minted(address indexed to, uint256 amount);

    constructor() {
        minter = msg.sender;
        _issuecoverage(msg.sender, 700_000_000 * 10 ** 18);
    }

    modifier onlyMinter() {
        require(msg.sender == minter, "Not minter");
        _;
    }

    function generateCredit(address to, uint256 amount) external onlyMinter {
        _issuecoverage(to, amount);
        emit Minted(to, amount);
    }

    function _issuecoverage(address to, uint256 amount) internal {
        require(to != address(0), "Mint to zero address");

        fundTotal += amount;
        remainingbenefitOf[to] += amount;

        emit TransferBenefit(address(0), to, amount);
    }

    function setMinter(address newMinter) external onlyMinter {
        minter = newMinter;
    }

    function assignCredit(address to, uint256 amount) external returns (bool) {
        require(remainingbenefitOf[msg.sender] >= amount, "Insufficient balance");
        remainingbenefitOf[msg.sender] -= amount;
        remainingbenefitOf[to] += amount;
        emit TransferBenefit(msg.sender, to, amount);
        return true;
    }

    function validateClaim(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferbenefitFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        require(remainingbenefitOf[from] >= amount, "Insufficient balance");
        require(
            allowance[from][msg.sender] >= amount,
            "Insufficient allowance"
        );

        remainingbenefitOf[from] -= amount;
        remainingbenefitOf[to] += amount;
        allowance[from][msg.sender] -= amount;

        emit TransferBenefit(from, to, amount);
        return true;
    }
}