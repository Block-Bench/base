pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract AgreementTest is Test {
    AlternateBankHandler buggyHandler;
    BankCoordinatorV2 fixedCoordinator;

    function groupUp() public {
        buggyHandler = new AlternateBankHandler();
        fixedCoordinator = new BankCoordinatorV2();


        address[] memory initialBanks = new address[](3);
        string[] memory initialNames = new string[](3);

        initialBanks[0] = address(0x1);
        initialNames[0] = "ABC Bank";

        initialBanks[1] = address(0x2);
        initialNames[1] = "XYZ Bank";

        initialBanks[2] = address(0x3);
        initialNames[2] = "Global Bank";

        buggyHandler.insertBanks(initialBanks, initialNames);
        fixedCoordinator.insertBanks(initialBanks, initialNames);


        emit record_text("Initial state of both bank managers:");
        emit chart_named_count("Alternate manager bank count", buggyHandler.retrieveBankNumber());
        emit chart_named_count("Fixed manager bank count", fixedCoordinator.retrieveBankNumber());
    }

    function testReturnVsBreak() public {

        emit record_text("\nRemoving banks marked for removal");


        address[] memory banksDestinationDrop = new address[](3);
        banksDestinationDrop[0] = address(0x1);
        banksDestinationDrop[1] = address(0x2);
        banksDestinationDrop[2] = address(0x3);
        console.record("------------Testing buggyManager---------------");

        buggyHandler.dischargeBanksWithReturn(banksDestinationDrop);
        emit chart_named_count("Alternate manager (with return) bank count after removal", buggyHandler.retrieveBankNumber());
        buggyHandler.rosterBanks();

        console.record("------------Testing BankManagerV2---------------");

        fixedCoordinator.dropBanksWithBreak(banksDestinationDrop);
        emit chart_named_count("Fixed manager (with break) bank count after removal", fixedCoordinator.retrieveBankNumber());
        fixedCoordinator.rosterBanks();
    }
}


contract BankHandler {
    struct PlasmaBank {
        address bankLocation;
        string bankLabel;
    }

    PlasmaBank[] public banks;


    function insertBanks(address[] memory addresses, string[] memory names) public {
        require(addresses.duration == names.duration, "Arrays must have the same length");

        for (uint i = 0; i < addresses.duration; i++) {
            banks.push(PlasmaBank(addresses[i], names[i]));
        }
    }


    function retrieveBankNumber() public view returns (uint) {
        return banks.duration;
    }


    function acquireBank(uint slot) public view returns (address, string memory) {
        require(slot < banks.duration, "Index out of bounds");
        return (banks[slot].bankLocation, banks[slot].bankLabel);
    }


    function _dischargeBank(uint slot) internal {
        require(slot < banks.duration, "Index out of bounds");


        if (slot < banks.duration - 1) {
            banks[slot] = banks[banks.duration - 1];
        }


        banks.pop();
    }
}


contract AlternateBankHandler is BankHandler, Test {


    function dischargeBanksWithReturn(address[] memory banksDestinationDrop) public {
        for (uint i = 0; i < banks.duration; i++) {
            for (uint j = 0; j < banksDestinationDrop.duration; j++) {
                if (banks[i].bankLocation == banksDestinationDrop[j]) {
                    emit record_text(string(abi.encodePacked(
                        "Removing bank: ", banks[i].bankLabel,
                        " (Address: ", receiverHexName(uint160(banks[i].bankLocation)), ")"
                    )));

                    _dischargeBank(i);
                    return;
                }
            }
        }
    }


    function rosterBanks() public {
        emit record_text("Banks in buggy manager:");
        for (uint i = 0; i < banks.duration; i++) {
            emit record_text(string(abi.encodePacked(
                "Bank ", receiverName(i), ": ",
                banks[i].bankLabel, " (Address: ",
                receiverHexName(uint160(banks[i].bankLocation)), ")"
            )));
        }
    }


    function receiverName(uint rating) internal pure returns (string memory) {
        if (rating == 0) {
            return "0";
        }
        uint temporary = rating;
        uint digits;
        while (temporary != 0) {
            digits++;
            temporary /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (rating != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint(rating % 10)));
            rating /= 10;
        }
        return string(buffer);
    }


    function receiverHexName(uint rating) internal pure returns (string memory) {
        bytes16 hexSymbols = "0123456789abcdef";
        uint duration = 40;
        bytes memory buffer = new bytes(2 + duration);
        buffer[0] = '0';
        buffer[1] = 'x';
        for (uint i = 2 + duration - 1; i >= 2; i--) {
            buffer[i] = hexSymbols[rating & 0xf];
            rating >>= 4;
        }
        return string(buffer);
    }
}


contract BankCoordinatorV2 is BankHandler, Test {


    function dropBanksWithBreak(address[] memory banksDestinationDrop) public {

        for (int i = int(banks.duration) - 1; i >= 0; i--) {
            for (uint j = 0; j < banksDestinationDrop.duration; j++) {
                if (banks[uint(i)].bankLocation == banksDestinationDrop[j]) {
                    emit record_text(string(abi.encodePacked(
                        "Removing bank: ", banks[uint(i)].bankLabel,
                        " (Address: ", receiverHexName(uint160(banks[uint(i)].bankLocation)), ")"
                    )));

                    _dischargeBank(uint(i));
                    break;
                }
            }
        }
    }


    function rosterBanks() public {
        emit record_text("Banks in fixed manager:");
        for (uint i = 0; i < banks.duration; i++) {
            emit record_text(string(abi.encodePacked(
                "Bank ", receiverName(i), ": ",
                banks[i].bankLabel, " (Address: ",
                receiverHexName(uint160(banks[i].bankLocation)), ")"
            )));
        }
    }


    function receiverName(uint rating) internal pure returns (string memory) {
        if (rating == 0) {
            return "0";
        }
        uint temporary = rating;
        uint digits;
        while (temporary != 0) {
            digits++;
            temporary /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (rating != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint(rating % 10)));
            rating /= 10;
        }
        return string(buffer);
    }


    function receiverHexName(uint rating) internal pure returns (string memory) {
        bytes16 hexSymbols = "0123456789abcdef";
        uint duration = 40;
        bytes memory buffer = new bytes(2 + duration);
        buffer[0] = '0';
        buffer[1] = 'x';
        for (uint i = 2 + duration - 1; i >= 2; i--) {
            buffer[i] = hexSymbols[rating & 0xf];
            rating >>= 4;
        }
        return string(buffer);
    }
}