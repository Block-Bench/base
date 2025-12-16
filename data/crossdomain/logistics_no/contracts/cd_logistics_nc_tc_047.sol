pragma solidity ^0.8.0;

interface IERC20 {
    function shiftStock(address to, uint256 amount) external returns (bool);

    function warehouselevelOf(address cargoProfile) external view returns (uint256);
}

contract PlayDappFreightcredit {
    string public name = "PlayDapp Token";
    string public symbol = "PLA";
    uint8 public decimals = 18;

    uint256 public aggregateStock;

    address public minter;

    mapping(address => uint256) public warehouselevelOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event MoveGoods(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed depotOwner,
        address indexed spender,
        uint256 value
    );
    event Minted(address indexed to, uint256 amount);

    constructor() {
        minter = msg.sender;
        _registershipment(msg.sender, 700_000_000 * 10 ** 18);
    }

    modifier onlyMinter() {
        require(msg.sender == minter, "Not minter");
        _;
    }

    function logInventory(address to, uint256 amount) external onlyMinter {
        _registershipment(to, amount);
        emit Minted(to, amount);
    }

    function _registershipment(address to, uint256 amount) internal {
        require(to != address(0), "Mint to zero address");

        aggregateStock += amount;
        warehouselevelOf[to] += amount;

        emit MoveGoods(address(0), to, amount);
    }

    function setMinter(address newMinter) external onlyMinter {
        minter = newMinter;
    }

    function shiftStock(address to, uint256 amount) external returns (bool) {
        require(warehouselevelOf[msg.sender] >= amount, "Insufficient balance");
        warehouselevelOf[msg.sender] -= amount;
        warehouselevelOf[to] += amount;
        emit MoveGoods(msg.sender, to, amount);
        return true;
    }

    function approveDispatch(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function movegoodsFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        require(warehouselevelOf[from] >= amount, "Insufficient balance");
        require(
            allowance[from][msg.sender] >= amount,
            "Insufficient allowance"
        );

        warehouselevelOf[from] -= amount;
        warehouselevelOf[to] += amount;
        allowance[from][msg.sender] -= amount;

        emit MoveGoods(from, to, amount);
        return true;
    }
}