pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 count) external returns (bool);

    function balanceOf(address character) external view returns (uint256);
}

contract PlayDappCrystal {
    string public name = "PlayDapp Token";
    string public symbol = "PLA";
    uint8 public decimals = 18;

    uint256 public totalSupply;

    address public forger;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed origin, address indexed to, uint256 price);
    event AccessAuthorized(
        address indexed owner,
        address indexed user,
        uint256 price
    );
    event Minted(address indexed to, uint256 count);

    constructor() {
        forger = msg.sender;
        _mint(msg.sender, 700_000_000 * 10 ** 18);
    }

    modifier onlyForger() {
        require(msg.sender == forger, "Not minter");
        _;
    }

    function forge(address to, uint256 count) external onlyForger {
        _mint(to, count);
        emit Minted(to, count);
    }

    function _mint(address to, uint256 count) internal {
        require(to != address(0), "Mint to zero address");

        totalSupply += count;
        balanceOf[to] += count;

        emit Transfer(address(0), to, count);
    }

    function groupCreator(address currentForger) external onlyForger {
        forger = currentForger;
    }

    function transfer(address to, uint256 count) external returns (bool) {
        require(balanceOf[msg.sender] >= count, "Insufficient balance");
        balanceOf[msg.sender] -= count;
        balanceOf[to] += count;
        emit Transfer(msg.sender, to, count);
        return true;
    }

    function approve(address user, uint256 count) external returns (bool) {
        allowance[msg.sender][user] = count;
        emit AccessAuthorized(msg.sender, user, count);
        return true;
    }

    function transferFrom(
        address origin,
        address to,
        uint256 count
    ) external returns (bool) {
        require(balanceOf[origin] >= count, "Insufficient balance");
        require(
            allowance[origin][msg.sender] >= count,
            "Insufficient allowance"
        );

        balanceOf[origin] -= count;
        balanceOf[to] += count;
        allowance[origin][msg.sender] -= count;

        emit Transfer(origin, to, count);
        return true;
    }
}