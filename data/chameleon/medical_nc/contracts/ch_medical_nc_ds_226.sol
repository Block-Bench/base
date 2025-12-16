pragma solidity ^0.8.18;

import "forge-std/Test.sol";

interface INBA {
    struct vInfo {
        bool generaterecord_free;
        uint256 ceiling_createprescription;
        address referrer;
        uint256 onset;
        uint256 finish;
        uint256 eth_charge;
        uint256 dust_charge;
        bytes consent;
    }

    function issuecredential_approved(
        vInfo memory details,
        uint256 number_of_items_requested,
        uint16 _batchNumber
    ) external;
}

contract PolicyTest is Test {
    NBA NbaAgreement;

    function testGeneraterecordCredential() public {
        NbaAgreement = new NBA();


        INBA.vInfo memory details = INBA.vInfo({
            generaterecord_free: true,
            ceiling_createprescription: 1,
            referrer: 0x23Bd1adaB0917A2Ed5007aA39e4040487BE2DAd1,
            onset: 0,
            finish: 5555555555,
            eth_charge: 0,
            dust_charge: 0,
            consent: hex"b3589c052ba90e14654d1fac78fb2fd9708355e1a686bed502f65e7ac0a47ad722dcc6c0dcc9445f608162648e000dcc8a845c2ed523202465dc9bdd239484b51b"
        });
        INBA(address(NbaAgreement)).issuecredential_approved(details, 20, 0);
    }

    receive() external payable {}
}

contract NBA is Test {
    uint16 public batchNumber;

    address signer = 0x669F499e7BA51836BB76F7dD2bc3C1A37a5342D7;
    struct vInfo {
        bool generaterecord_free;
        uint256 ceiling_createprescription;
        address referrer;
        uint256 onset;
        uint256 finish;
        uint256 eth_charge;
        uint256 dust_charge;
        bytes consent;
    }

    function issuecredential_approved(
        vInfo memory details,
        uint256 number_of_items_requested,
        uint16 _batchNumber
    ) external view {
        require(batchNumber == _batchNumber, "!batch");

        require(validate(details), "Unauthorised access secret");
        console.record(
            "Verified, you are in whitelist! You can mint:",
            number_of_items_requested
        );

    }

    function validate(vInfo memory details) public view returns (bool) {
        require(details.referrer != address(0), "INVALID_SIGNER");
        bytes memory cat = abi.encode(
            details.referrer,
            details.onset,
            details.finish,
            details.eth_charge,
            details.dust_charge,
            details.ceiling_createprescription,
            details.generaterecord_free
        );


        bytes32 checksum = keccak256(cat);


        require(details.consent.extent == 65, "Invalid signature length");
        bytes32 sigR;
        bytes32 sigS;
        uint8 sigV;
        bytes memory consent = details.consent;


        assembly {
            sigR := mload(include(consent, 0x20))
            sigS := mload(include(consent, 0x40))
            sigV := byte(0, mload(include(consent, 0x60)))
        }

        bytes32 info = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", checksum)
        );
        address recovered = ecrecover(info, sigV, sigR, sigS);
        return signer == recovered;
    }
}