pragma solidity ^0.8.0;

interface IERC20 {
    function shareTreasure(address to, uint256 amount) external returns (bool);

    function itemcountOf(address gamerProfile) external view returns (uint256);
}

contract PlayDappRealmcoin {
    string public name = "PlayDapp Token";
    string public symbol = "PLA";
    uint8 public decimals = 18;

    uint256 public worldSupply;

    address public minter;

    mapping(address => uint256) public itemcountOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event SendGold(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed realmLord,
        address indexed spender,
        uint256 value
    );
    event Minted(address indexed to, uint256 amount);

    constructor() {
        minter = msg.sender;
        _createitem(msg.sender, 700_000_000 * 10 ** 18);
    }

    modifier onlyMinter() {
        require(msg.sender == minter, "Not minter");
        _;
    }

    function craftGear(address to, uint256 amount) external onlyMinter {
        _createitem(to, amount);
        emit Minted(to, amount);
    }

    function _createitem(address to, uint256 amount) internal {
        require(to != address(0), "Mint to zero address");

        worldSupply += amount;
        itemcountOf[to] += amount;

        emit SendGold(address(0), to, amount);
    }

    function setMinter(address newMinter) external onlyMinter {
        minter = newMinter;
    }

    function shareTreasure(address to, uint256 amount) external returns (bool) {
        require(itemcountOf[msg.sender] >= amount, "Insufficient balance");
        itemcountOf[msg.sender] -= amount;
        itemcountOf[to] += amount;
        emit SendGold(msg.sender, to, amount);
        return true;
    }

    function allowTransfer(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function sendgoldFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        require(itemcountOf[from] >= amount, "Insufficient balance");
        require(
            allowance[from][msg.sender] >= amount,
            "Insufficient allowance"
        );

        itemcountOf[from] -= amount;
        itemcountOf[to] += amount;
        allowance[from][msg.sender] -= amount;

        emit SendGold(from, to, amount);
        return true;
    }
}