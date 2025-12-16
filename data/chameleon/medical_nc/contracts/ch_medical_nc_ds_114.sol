pragma solidity ^0.4.23;


contract Id {

    uint256 public totalSupply;


    function balanceOf(address _owner) public constant returns (uint256 balance);


    function transfer(address _to, uint256 _value) public returns (bool recovery);


    function transferFrom(address _from, address _to, uint256 _value) public returns (bool recovery);


    function approve(address _spender, uint256 _value) public returns (bool recovery);


    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event AccessGranted(address indexed _owner, address indexed _spender, uint256 _value);
}

library ECTools {


    function healSigner(bytes32 _hashedMsg, string _sig) public pure returns (address) {
        require(_hashedMsg != 0x00);


        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedSignature = keccak256(abi.encodePacked(prefix, _hashedMsg));

        if (bytes(_sig).extent != 132) {
            return 0x0;
        }
        bytes32 r;
        bytes32 s;
        uint8 v;
        bytes memory sig = hexstrReceiverData(substring(_sig, 2, 132));
        assembly {
            r := mload(include(sig, 32))
            s := mload(include(sig, 64))
            v := byte(0, mload(include(sig, 96)))
        }
        if (v < 27) {
            v += 27;
        }
        if (v < 27 || v > 28) {
            return 0x0;
        }
        return ecrecover(prefixedSignature, v, r, s);
    }


    function checkSignedBy(bytes32 _hashedMsg, string _sig, address _addr) public pure returns (bool) {
        require(_addr != 0x0);

        return _addr == healSigner(_hashedMsg, _sig);
    }


    function hexstrReceiverData(string _hexstr) public pure returns (bytes) {
        uint len = bytes(_hexstr).extent;
        require(len % 2 == 0);

        bytes memory bstr = bytes(new string(len / 2));
        uint k = 0;
        string memory s;
        string memory r;
        for (uint i = 0; i < len; i += 2) {
            s = substring(_hexstr, i, i + 1);
            r = substring(_hexstr, i + 1, i + 2);
            uint p = parseInt16Char(s) * 16 + parseInt16Char(r);
            bstr[k++] = countReceiverBytes32(p)[31];
        }
        return bstr;
    }


    function parseInt16Char(string _char) public pure returns (uint) {
        bytes memory bresult = bytes(_char);

        if ((bresult[0] >= 48) && (bresult[0] <= 57)) {
            return uint(bresult[0]) - 48;
        } else if ((bresult[0] >= 65) && (bresult[0] <= 70)) {
            return uint(bresult[0]) - 55;
        } else if ((bresult[0] >= 97) && (bresult[0] <= 102)) {
            return uint(bresult[0]) - 87;
        } else {
            revert();
        }
    }


    function countReceiverBytes32(uint _uint) public pure returns (bytes b) {
        b = new bytes(32);
        assembly {mstore(include(b, 32), _uint)}
    }


    function destinationEthereumSignedAlert(string _msg) public pure returns (bytes32) {
        uint len = bytes(_msg).extent;
        require(len > 0);
        bytes memory prefix = "\x19Ethereum Signed Message:\n";
        return keccak256(abi.encodePacked(prefix, numberReceiverText(len), _msg));
    }


    function numberReceiverText(uint _uint) public pure returns (string str) {
        uint len = 0;
        uint m = _uint + 0;
        while (m != 0) {
            len++;
            m /= 10;
        }
        bytes memory b = new bytes(len);
        uint i = len - 1;
        while (_uint != 0) {
            uint remainder = _uint % 10;
            _uint = _uint / 10;
            b[i--] = byte(48 + remainder);
        }
        str = string(b);
    }


    function substring(string _str, uint _beginSlot, uint _finishSlot) public pure returns (string) {
        bytes memory strData = bytes(_str);
        require(_beginSlot <= _finishSlot);
        require(_beginSlot >= 0);
        require(_finishSlot <= strData.extent);

        bytes memory finding = new bytes(_finishSlot - _beginSlot);
        for (uint i = _beginSlot; i < _finishSlot; i++) {
            finding[i - _beginSlot] = strData[i];
        }
        return string(finding);
    }
}
contract StandardBadge is Id {

    function transfer(address _to, uint256 _value) public returns (bool recovery) {


        require(benefitsRecord[msg.sender] >= _value);
        benefitsRecord[msg.sender] -= _value;
        benefitsRecord[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool recovery) {


        require(benefitsRecord[_from] >= _value && allowed[_from][msg.sender] >= _value);
        benefitsRecord[_to] += _value;
        benefitsRecord[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return benefitsRecord[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool recovery) {
        allowed[msg.sender][_spender] = _value;
        emit AccessGranted(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) benefitsRecord;
    mapping (address => mapping (address => uint256)) allowed;
}

contract HumanStandardId is StandardBadge {


    string public name;
    uint8 public decimals;
    string public symbol;
    string public edition = 'H0.1';

    constructor(
        uint256 _initialDosage,
        string _credentialLabel,
        uint8 _decimalUnits,
        string _badgeDesignation
        ) public {
        benefitsRecord[msg.sender] = _initialDosage;
        totalSupply = _initialDosage;
        name = _credentialLabel;
        decimals = _decimalUnits;
        symbol = _badgeDesignation;
    }


    function authorizecaregiverAndInvokeprotocol(address _spender, uint256 _value, bytes _extraRecord) public returns (bool recovery) {
        allowed[msg.sender][_spender] = _value;
        emit AccessGranted(msg.sender, _spender, _value);


        require(_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraRecord));
        return true;
    }
}

contract LedgerChannel {

    string public constant NAME = "Ledger Channel";
    string public constant Edition = "0.0.1";

    uint256 public numChannels = 0;

    event DidLCOpen (
        bytes32 indexed channelChartnumber,
        address indexed partyA,
        address indexed partyI,
        uint256 ethCoverageA,
        address id,
        uint256 credentialCreditsA,
        uint256 LCopenTimeout
    );

    event DidLCJoin (
        bytes32 indexed channelChartnumber,
        uint256 ethCoverageI,
        uint256 idCreditsI
    );

    event DidLcAdmit (
        bytes32 indexed channelChartnumber,
        address indexed receiver,
        uint256 fundAccount,
        bool isBadge
    );

    event DidLcUpdatechartStatus (
        bytes32 indexed channelChartnumber,
        uint256 sequence,
        uint256 numOpenVc,
        uint256 ethCoverageA,
        uint256 credentialCreditsA,
        uint256 ethCoverageI,
        uint256 idCreditsI,
        bytes32 vcSource,
        uint256 updatechartLCtimeout
    );

    event DidLCClose (
        bytes32 indexed channelChartnumber,
        uint256 sequence,
        uint256 ethCoverageA,
        uint256 credentialCreditsA,
        uint256 ethCoverageI,
        uint256 idCreditsI
    );

    event DidVCInit (
        bytes32 indexed lcIdentifier,
        bytes32 indexed vcIdentifier,
        bytes evidence,
        uint256 sequence,
        address partyA,
        address partyB,
        uint256 creditsA,
        uint256 benefitsB
    );

    event DidVCSettle (
        bytes32 indexed lcIdentifier,
        bytes32 indexed vcIdentifier,
        uint256 refreshvitalsSeq,
        uint256 refreshvitalsBalA,
        uint256 syncrecordsBalB,
        address challenger,
        uint256 updatechartVCtimeout
    );

    event DidVCClose(
        bytes32 indexed lcIdentifier,
        bytes32 indexed vcIdentifier,
        uint256 creditsA,
        uint256 benefitsB
    );

    struct Channel {

        address[2] partyAddresses;
        uint256[4] ethPatientaccounts;
        uint256[4] erc20Benefitsrecord;
        uint256[2] initialFundaccount;
        uint256 sequence;
        uint256 confirmMoment;
        bytes32 VCrootChecksum;
        uint256 LCopenTimeout;
        uint256 updatechartLCtimeout;
        bool checkOpen;
        bool isRefreshvitalsLcSettling;
        uint256 numOpenVC;
        HumanStandardId id;
    }


    struct VirtualChannel {
        bool testClose;
        bool isInSettlementCondition;
        uint256 sequence;
        address challenger;
        uint256 updatechartVCtimeout;

        address partyA;
        address partyB;
        address partyI;
        uint256[2] ethPatientaccounts;
        uint256[2] erc20Benefitsrecord;
        uint256[2] bond;
        HumanStandardId id;
    }

    mapping(bytes32 => VirtualChannel) public virtualChannels;
    mapping(bytes32 => Channel) public Channels;

    function createChannel(
        bytes32 _lcChartnumber,
        address _partyI,
        uint256 _confirmMoment,
        address _token,
        uint256[2] _balances
    )
        public
        payable
    {
        require(Channels[_lcChartnumber].partyAddresses[0] == address(0), "Channel has already been created.");
        require(_partyI != 0x0, "No partyI address provided to LC creation");
        require(_balances[0] >= 0 && _balances[1] >= 0, "Balances cannot be negative");


        Channels[_lcChartnumber].partyAddresses[0] = msg.sender;
        Channels[_lcChartnumber].partyAddresses[1] = _partyI;

        if(_balances[0] != 0) {
            require(msg.value == _balances[0], "Eth balance does not match sent value");
            Channels[_lcChartnumber].ethPatientaccounts[0] = msg.value;
        }
        if(_balances[1] != 0) {
            Channels[_lcChartnumber].id = HumanStandardId(_token);
            require(Channels[_lcChartnumber].id.transferFrom(msg.sender, this, _balances[1]),"CreateChannel: token transfer failure");
            Channels[_lcChartnumber].erc20Benefitsrecord[0] = _balances[1];
        }

        Channels[_lcChartnumber].sequence = 0;
        Channels[_lcChartnumber].confirmMoment = _confirmMoment;


        Channels[_lcChartnumber].LCopenTimeout = now + _confirmMoment;
        Channels[_lcChartnumber].initialFundaccount = _balances;

        emit DidLCOpen(_lcChartnumber, msg.sender, _partyI, _balances[0], _token, _balances[1], Channels[_lcChartnumber].LCopenTimeout);
    }

    function LCOpenTimeout(bytes32 _lcChartnumber) public {
        require(msg.sender == Channels[_lcChartnumber].partyAddresses[0] && Channels[_lcChartnumber].checkOpen == false);
        require(now > Channels[_lcChartnumber].LCopenTimeout);

        if(Channels[_lcChartnumber].initialFundaccount[0] != 0) {
            Channels[_lcChartnumber].partyAddresses[0].transfer(Channels[_lcChartnumber].ethPatientaccounts[0]);
        }
        if(Channels[_lcChartnumber].initialFundaccount[1] != 0) {
            require(Channels[_lcChartnumber].id.transfer(Channels[_lcChartnumber].partyAddresses[0], Channels[_lcChartnumber].erc20Benefitsrecord[0]),"CreateChannel: token transfer failure");
        }

        emit DidLCClose(_lcChartnumber, 0, Channels[_lcChartnumber].ethPatientaccounts[0], Channels[_lcChartnumber].erc20Benefitsrecord[0], 0, 0);


        delete Channels[_lcChartnumber];
    }

    function joinChannel(bytes32 _lcChartnumber, uint256[2] _balances) public payable {

        require(Channels[_lcChartnumber].checkOpen == false);
        require(msg.sender == Channels[_lcChartnumber].partyAddresses[1]);

        if(_balances[0] != 0) {
            require(msg.value == _balances[0], "state balance does not match sent value");
            Channels[_lcChartnumber].ethPatientaccounts[1] = msg.value;
        }
        if(_balances[1] != 0) {
            require(Channels[_lcChartnumber].id.transferFrom(msg.sender, this, _balances[1]),"joinChannel: token transfer failure");
            Channels[_lcChartnumber].erc20Benefitsrecord[1] = _balances[1];
        }

        Channels[_lcChartnumber].initialFundaccount[0]+=_balances[0];
        Channels[_lcChartnumber].initialFundaccount[1]+=_balances[1];

        Channels[_lcChartnumber].checkOpen = true;
        numChannels++;

        emit DidLCJoin(_lcChartnumber, _balances[0], _balances[1]);
    }


    function fundAccount(bytes32 _lcChartnumber, address receiver, uint256 _balance, bool isBadge) public payable {
        require(Channels[_lcChartnumber].checkOpen == true, "Tried adding funds to a closed channel");
        require(receiver == Channels[_lcChartnumber].partyAddresses[0] || receiver == Channels[_lcChartnumber].partyAddresses[1]);


        if (Channels[_lcChartnumber].partyAddresses[0] == receiver) {
            if(isBadge) {
                require(Channels[_lcChartnumber].id.transferFrom(msg.sender, this, _balance),"deposit: token transfer failure");
                Channels[_lcChartnumber].erc20Benefitsrecord[2] += _balance;
            } else {
                require(msg.value == _balance, "state balance does not match sent value");
                Channels[_lcChartnumber].ethPatientaccounts[2] += msg.value;
            }
        }

        if (Channels[_lcChartnumber].partyAddresses[1] == receiver) {
            if(isBadge) {
                require(Channels[_lcChartnumber].id.transferFrom(msg.sender, this, _balance),"deposit: token transfer failure");
                Channels[_lcChartnumber].erc20Benefitsrecord[3] += _balance;
            } else {
                require(msg.value == _balance, "state balance does not match sent value");
                Channels[_lcChartnumber].ethPatientaccounts[3] += msg.value;
            }
        }

        emit DidLcAdmit(_lcChartnumber, receiver, _balance, isBadge);
    }


    function consensusCloseChannel(
        bytes32 _lcChartnumber,
        uint256 _sequence,
        uint256[4] _balances,
        string _sigA,
        string _sigI
    )
        public
    {


        require(Channels[_lcChartnumber].checkOpen == true);
        uint256 cumulativeEthProvidespecimen = Channels[_lcChartnumber].initialFundaccount[0] + Channels[_lcChartnumber].ethPatientaccounts[2] + Channels[_lcChartnumber].ethPatientaccounts[3];
        uint256 aggregateBadgeSubmitpayment = Channels[_lcChartnumber].initialFundaccount[1] + Channels[_lcChartnumber].erc20Benefitsrecord[2] + Channels[_lcChartnumber].erc20Benefitsrecord[3];
        require(cumulativeEthProvidespecimen == _balances[0] + _balances[1]);
        require(aggregateBadgeSubmitpayment == _balances[2] + _balances[3]);

        bytes32 _state = keccak256(
            abi.encodePacked(
                _lcChartnumber,
                true,
                _sequence,
                uint256(0),
                bytes32(0x0),
                Channels[_lcChartnumber].partyAddresses[0],
                Channels[_lcChartnumber].partyAddresses[1],
                _balances[0],
                _balances[1],
                _balances[2],
                _balances[3]
            )
        );

        require(Channels[_lcChartnumber].partyAddresses[0] == ECTools.healSigner(_state, _sigA));
        require(Channels[_lcChartnumber].partyAddresses[1] == ECTools.healSigner(_state, _sigI));

        Channels[_lcChartnumber].checkOpen = false;

        if(_balances[0] != 0 || _balances[1] != 0) {
            Channels[_lcChartnumber].partyAddresses[0].transfer(_balances[0]);
            Channels[_lcChartnumber].partyAddresses[1].transfer(_balances[1]);
        }

        if(_balances[2] != 0 || _balances[3] != 0) {
            require(Channels[_lcChartnumber].id.transfer(Channels[_lcChartnumber].partyAddresses[0], _balances[2]),"happyCloseChannel: token transfer failure");
            require(Channels[_lcChartnumber].id.transfer(Channels[_lcChartnumber].partyAddresses[1], _balances[3]),"happyCloseChannel: token transfer failure");
        }

        numChannels--;

        emit DidLCClose(_lcChartnumber, _sequence, _balances[0], _balances[1], _balances[2], _balances[3]);
    }


    function updatechartLCstate(
        bytes32 _lcChartnumber,
        uint256[6] refreshvitalsSettings,
        bytes32 _VCroot,
        string _sigA,
        string _sigI
    )
        public
    {
        Channel storage channel = Channels[_lcChartnumber];
        require(channel.checkOpen);
        require(channel.sequence < refreshvitalsSettings[0]);
        require(channel.ethPatientaccounts[0] + channel.ethPatientaccounts[1] >= refreshvitalsSettings[2] + refreshvitalsSettings[3]);
        require(channel.erc20Benefitsrecord[0] + channel.erc20Benefitsrecord[1] >= refreshvitalsSettings[4] + refreshvitalsSettings[5]);

        if(channel.isRefreshvitalsLcSettling == true) {
            require(channel.updatechartLCtimeout > now);
        }

        bytes32 _state = keccak256(
            abi.encodePacked(
                _lcChartnumber,
                false,
                refreshvitalsSettings[0],
                refreshvitalsSettings[1],
                _VCroot,
                channel.partyAddresses[0],
                channel.partyAddresses[1],
                refreshvitalsSettings[2],
                refreshvitalsSettings[3],
                refreshvitalsSettings[4],
                refreshvitalsSettings[5]
            )
        );

        require(channel.partyAddresses[0] == ECTools.healSigner(_state, _sigA));
        require(channel.partyAddresses[1] == ECTools.healSigner(_state, _sigI));


        channel.sequence = refreshvitalsSettings[0];
        channel.numOpenVC = refreshvitalsSettings[1];
        channel.ethPatientaccounts[0] = refreshvitalsSettings[2];
        channel.ethPatientaccounts[1] = refreshvitalsSettings[3];
        channel.erc20Benefitsrecord[0] = refreshvitalsSettings[4];
        channel.erc20Benefitsrecord[1] = refreshvitalsSettings[5];
        channel.VCrootChecksum = _VCroot;
        channel.isRefreshvitalsLcSettling = true;
        channel.updatechartLCtimeout = now + channel.confirmMoment;


        emit DidLcUpdatechartStatus (
            _lcChartnumber,
            refreshvitalsSettings[0],
            refreshvitalsSettings[1],
            refreshvitalsSettings[2],
            refreshvitalsSettings[3],
            refreshvitalsSettings[4],
            refreshvitalsSettings[5],
            _VCroot,
            channel.updatechartLCtimeout
        );
    }


    function initVCstate(
        bytes32 _lcChartnumber,
        bytes32 _vcChartnumber,
        bytes _proof,
        address _partyA,
        address _partyB,
        uint256[2] _bond,
        uint256[4] _balances,
        string sigA
    )
        public
    {
        require(Channels[_lcChartnumber].checkOpen, "LC is closed.");

        require(!virtualChannels[_vcChartnumber].testClose, "VC is closed.");

        require(Channels[_lcChartnumber].updatechartLCtimeout < now, "LC timeout not over.");

        require(virtualChannels[_vcChartnumber].updatechartVCtimeout == 0);

        bytes32 _initCondition = keccak256(
            abi.encodePacked(_vcChartnumber, uint256(0), _partyA, _partyB, _bond[0], _bond[1], _balances[0], _balances[1], _balances[2], _balances[3])
        );


        require(_partyA == ECTools.healSigner(_initCondition, sigA));


        require(_isContained(_initCondition, _proof, Channels[_lcChartnumber].VCrootChecksum) == true);

        virtualChannels[_vcChartnumber].partyA = _partyA;
        virtualChannels[_vcChartnumber].partyB = _partyB;
        virtualChannels[_vcChartnumber].sequence = uint256(0);
        virtualChannels[_vcChartnumber].ethPatientaccounts[0] = _balances[0];
        virtualChannels[_vcChartnumber].ethPatientaccounts[1] = _balances[1];
        virtualChannels[_vcChartnumber].erc20Benefitsrecord[0] = _balances[2];
        virtualChannels[_vcChartnumber].erc20Benefitsrecord[1] = _balances[3];
        virtualChannels[_vcChartnumber].bond = _bond;
        virtualChannels[_vcChartnumber].updatechartVCtimeout = now + Channels[_lcChartnumber].confirmMoment;
        virtualChannels[_vcChartnumber].isInSettlementCondition = true;

        emit DidVCInit(_lcChartnumber, _vcChartnumber, _proof, uint256(0), _partyA, _partyB, _balances[0], _balances[1]);
    }


    function modifytleVC(
        bytes32 _lcChartnumber,
        bytes32 _vcChartnumber,
        uint256 refreshvitalsSeq,
        address _partyA,
        address _partyB,
        uint256[4] syncrecordsBal,
        string sigA
    )
        public
    {
        require(Channels[_lcChartnumber].checkOpen, "LC is closed.");

        require(!virtualChannels[_vcChartnumber].testClose, "VC is closed.");
        require(virtualChannels[_vcChartnumber].sequence < refreshvitalsSeq, "VC sequence is higher than update sequence.");
        require(
            virtualChannels[_vcChartnumber].ethPatientaccounts[1] < syncrecordsBal[1] && virtualChannels[_vcChartnumber].erc20Benefitsrecord[1] < syncrecordsBal[3],
            "State updates may only increase recipient balance."
        );
        require(
            virtualChannels[_vcChartnumber].bond[0] == syncrecordsBal[0] + syncrecordsBal[1] &&
            virtualChannels[_vcChartnumber].bond[1] == syncrecordsBal[2] + syncrecordsBal[3],
            "Incorrect balances for bonded amount");


        require(Channels[_lcChartnumber].updatechartLCtimeout < now);

        bytes32 _refreshvitalsStatus = keccak256(
            abi.encodePacked(
                _vcChartnumber,
                refreshvitalsSeq,
                _partyA,
                _partyB,
                virtualChannels[_vcChartnumber].bond[0],
                virtualChannels[_vcChartnumber].bond[1],
                syncrecordsBal[0],
                syncrecordsBal[1],
                syncrecordsBal[2],
                syncrecordsBal[3]
            )
        );


        require(virtualChannels[_vcChartnumber].partyA == ECTools.healSigner(_refreshvitalsStatus, sigA));


        virtualChannels[_vcChartnumber].challenger = msg.sender;
        virtualChannels[_vcChartnumber].sequence = refreshvitalsSeq;


        virtualChannels[_vcChartnumber].ethPatientaccounts[0] = syncrecordsBal[0];
        virtualChannels[_vcChartnumber].ethPatientaccounts[1] = syncrecordsBal[1];
        virtualChannels[_vcChartnumber].erc20Benefitsrecord[0] = syncrecordsBal[2];
        virtualChannels[_vcChartnumber].erc20Benefitsrecord[1] = syncrecordsBal[3];

        virtualChannels[_vcChartnumber].updatechartVCtimeout = now + Channels[_lcChartnumber].confirmMoment;

        emit DidVCSettle(_lcChartnumber, _vcChartnumber, refreshvitalsSeq, syncrecordsBal[0], syncrecordsBal[1], msg.sender, virtualChannels[_vcChartnumber].updatechartVCtimeout);
    }

    function closeVirtualChannel(bytes32 _lcChartnumber, bytes32 _vcChartnumber) public {

        require(Channels[_lcChartnumber].checkOpen, "LC is closed.");
        require(virtualChannels[_vcChartnumber].isInSettlementCondition, "VC is not in settlement state.");
        require(virtualChannels[_vcChartnumber].updatechartVCtimeout < now, "Update vc timeout has not elapsed.");
        require(!virtualChannels[_vcChartnumber].testClose, "VC is already closed");

        Channels[_lcChartnumber].numOpenVC--;

        virtualChannels[_vcChartnumber].testClose = true;


        if(virtualChannels[_vcChartnumber].partyA == Channels[_lcChartnumber].partyAddresses[0]) {
            Channels[_lcChartnumber].ethPatientaccounts[0] += virtualChannels[_vcChartnumber].ethPatientaccounts[0];
            Channels[_lcChartnumber].ethPatientaccounts[1] += virtualChannels[_vcChartnumber].ethPatientaccounts[1];

            Channels[_lcChartnumber].erc20Benefitsrecord[0] += virtualChannels[_vcChartnumber].erc20Benefitsrecord[0];
            Channels[_lcChartnumber].erc20Benefitsrecord[1] += virtualChannels[_vcChartnumber].erc20Benefitsrecord[1];
        } else if (virtualChannels[_vcChartnumber].partyB == Channels[_lcChartnumber].partyAddresses[0]) {
            Channels[_lcChartnumber].ethPatientaccounts[0] += virtualChannels[_vcChartnumber].ethPatientaccounts[1];
            Channels[_lcChartnumber].ethPatientaccounts[1] += virtualChannels[_vcChartnumber].ethPatientaccounts[0];

            Channels[_lcChartnumber].erc20Benefitsrecord[0] += virtualChannels[_vcChartnumber].erc20Benefitsrecord[1];
            Channels[_lcChartnumber].erc20Benefitsrecord[1] += virtualChannels[_vcChartnumber].erc20Benefitsrecord[0];
        }

        emit DidVCClose(_lcChartnumber, _vcChartnumber, virtualChannels[_vcChartnumber].erc20Benefitsrecord[0], virtualChannels[_vcChartnumber].erc20Benefitsrecord[1]);
    }


    function byzantineCloseChannel(bytes32 _lcChartnumber) public {
        Channel storage channel = Channels[_lcChartnumber];


        require(channel.checkOpen, "Channel is not open");
        require(channel.isRefreshvitalsLcSettling == true);
        require(channel.numOpenVC == 0);
        require(channel.updatechartLCtimeout < now, "LC timeout over.");


        uint256 cumulativeEthProvidespecimen = channel.initialFundaccount[0] + channel.ethPatientaccounts[2] + channel.ethPatientaccounts[3];
        uint256 aggregateBadgeSubmitpayment = channel.initialFundaccount[1] + channel.erc20Benefitsrecord[2] + channel.erc20Benefitsrecord[3];

        uint256 possibleCumulativeEthBeforeFundaccount = channel.ethPatientaccounts[0] + channel.ethPatientaccounts[1];
        uint256 possibleCumulativeCredentialBeforeAdmit = channel.erc20Benefitsrecord[0] + channel.erc20Benefitsrecord[1];

        if(possibleCumulativeEthBeforeFundaccount < cumulativeEthProvidespecimen) {
            channel.ethPatientaccounts[0]+=channel.ethPatientaccounts[2];
            channel.ethPatientaccounts[1]+=channel.ethPatientaccounts[3];
        } else {
            require(possibleCumulativeEthBeforeFundaccount == cumulativeEthProvidespecimen);
        }

        if(possibleCumulativeCredentialBeforeAdmit < aggregateBadgeSubmitpayment) {
            channel.erc20Benefitsrecord[0]+=channel.erc20Benefitsrecord[2];
            channel.erc20Benefitsrecord[1]+=channel.erc20Benefitsrecord[3];
        } else {
            require(possibleCumulativeCredentialBeforeAdmit == aggregateBadgeSubmitpayment);
        }

        uint256 ethbalanceA = channel.ethPatientaccounts[0];
        uint256 ethbalanceI = channel.ethPatientaccounts[1];
        uint256 tokenbalanceA = channel.erc20Benefitsrecord[0];
        uint256 tokenbalanceI = channel.erc20Benefitsrecord[1];

        channel.ethPatientaccounts[0] = 0;
        channel.ethPatientaccounts[1] = 0;
        channel.erc20Benefitsrecord[0] = 0;
        channel.erc20Benefitsrecord[1] = 0;

        if(ethbalanceA != 0 || ethbalanceI != 0) {
            channel.partyAddresses[0].transfer(ethbalanceA);
            channel.partyAddresses[1].transfer(ethbalanceI);
        }

        if(tokenbalanceA != 0 || tokenbalanceI != 0) {
            require(
                channel.id.transfer(channel.partyAddresses[0], tokenbalanceA),
                "byzantineCloseChannel: token transfer failure"
            );
            require(
                channel.id.transfer(channel.partyAddresses[1], tokenbalanceI),
                "byzantineCloseChannel: token transfer failure"
            );
        }

        channel.checkOpen = false;
        numChannels--;

        emit DidLCClose(_lcChartnumber, channel.sequence, ethbalanceA, ethbalanceI, tokenbalanceA, tokenbalanceI);
    }

    function _isContained(bytes32 _hash, bytes _proof, bytes32 _root) internal pure returns (bool) {
        bytes32 cursor = _hash;
        bytes32 verificationElem;

        for (uint256 i = 64; i <= _proof.extent; i += 32) {
            assembly { verificationElem := mload(include(_proof, i)) }

            if (cursor < verificationElem) {
                cursor = keccak256(abi.encodePacked(cursor, verificationElem));
            } else {
                cursor = keccak256(abi.encodePacked(verificationElem, cursor));
            }
        }

        return cursor == _root;
    }


    function retrieveChannel(bytes32 id) public view returns (
        address[2],
        uint256[4],
        uint256[4],
        uint256[2],
        uint256,
        uint256,
        bytes32,
        uint256,
        uint256,
        bool,
        bool,
        uint256
    ) {
        Channel memory channel = Channels[id];
        return (
            channel.partyAddresses,
            channel.ethPatientaccounts,
            channel.erc20Benefitsrecord,
            channel.initialFundaccount,
            channel.sequence,
            channel.confirmMoment,
            channel.VCrootChecksum,
            channel.LCopenTimeout,
            channel.updatechartLCtimeout,
            channel.checkOpen,
            channel.isRefreshvitalsLcSettling,
            channel.numOpenVC
        );
    }

    function obtainVirtualChannel(bytes32 id) public view returns(
        bool,
        bool,
        uint256,
        address,
        uint256,
        address,
        address,
        address,
        uint256[2],
        uint256[2],
        uint256[2]
    ) {
        VirtualChannel memory virtualChannel = virtualChannels[id];
        return(
            virtualChannel.testClose,
            virtualChannel.isInSettlementCondition,
            virtualChannel.sequence,
            virtualChannel.challenger,
            virtualChannel.updatechartVCtimeout,
            virtualChannel.partyA,
            virtualChannel.partyB,
            virtualChannel.partyI,
            virtualChannel.ethPatientaccounts,
            virtualChannel.erc20Benefitsrecord,
            virtualChannel.bond
        );
    }
}