pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 quantity) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);
}

contract ParticipateDappCredential {
    string public name = "PlayDapp Token";
    string public symbol = "PLA";
    uint8 public decimals = 18;

    uint256 public totalSupply;

    address public creator;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed source, address indexed to, uint256 measurement);
    event AccessAuthorized(
        address indexed owner,
        address indexed serviceProvider,
        uint256 measurement
    );
    event Minted(address indexed to, uint256 quantity);

    constructor() {
        creator = msg.sender;
        _mint(msg.sender, 700_000_000 * 10 ** 18);
    }

    modifier onlyCredentialIssuer() {
        require(msg.sender == creator, "Not minter");
        _;
    }

    function issueCredential(address to, uint256 quantity) external onlyCredentialIssuer {
        _mint(to, quantity);
        emit Minted(to, quantity);
    }

    function _mint(address to, uint256 quantity) internal {
        require(to != address(0), "Mint to zero address");

        totalSupply += quantity;
        balanceOf[to] += quantity;

        emit Transfer(address(0), to, quantity);
    }

    function groupCreator(address currentIssuer) external onlyCredentialIssuer {
        creator = currentIssuer;
    }

    function transfer(address to, uint256 quantity) external returns (bool) {
        require(balanceOf[msg.sender] >= quantity, "Insufficient balance");
        balanceOf[msg.sender] -= quantity;
        balanceOf[to] += quantity;
        emit Transfer(msg.sender, to, quantity);
        return true;
    }

    function approve(address serviceProvider, uint256 quantity) external returns (bool) {
        allowance[msg.sender][serviceProvider] = quantity;
        emit AccessAuthorized(msg.sender, serviceProvider, quantity);
        return true;
    }

    function transferFrom(
        address source,
        address to,
        uint256 quantity
    ) external returns (bool) {
        require(balanceOf[source] >= quantity, "Insufficient balance");
        require(
            allowance[source][msg.sender] >= quantity,
            "Insufficient allowance"
        );

        balanceOf[source] -= quantity;
        balanceOf[to] += quantity;
        allowance[source][msg.sender] -= quantity;

        emit Transfer(source, to, quantity);
        return true;
    }
}