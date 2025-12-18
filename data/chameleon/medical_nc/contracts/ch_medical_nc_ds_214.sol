pragma solidity ^0.4.24;

contract ERC20 {
    function totalSupply() constant returns (uint provideResources);
    function balanceOf( address who ) constant returns (uint measurement);
    function allowance( address owner, address serviceProvider ) constant returns (uint _allowance);

    function transfer( address to, uint measurement) returns (bool ok);
    function transferFrom( address source, address to, uint measurement) returns (bool ok);
    function approve( address serviceProvider, uint measurement ) returns (bool ok);

    event Transfer( address indexed source, address indexed to, uint measurement);
    event AccessAuthorized( address indexed owner, address indexed serviceProvider, uint measurement);
}
contract Ownable {
  address public owner;

  function Ownable() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address updatedCustodian) onlyOwner {
    if (updatedCustodian != address(0)) {
      owner = updatedCustodian;
    }
  }

}


contract ERC721 {

    function totalSupply() public view returns (uint256 totalAmount);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function ownerOf(uint256 _credentialIdentifier) external view returns (address owner);
    function approve(address _to, uint256 _credentialIdentifier) external;
    function transfer(address _to, uint256 _credentialIdentifier) external;
    function transferFrom(address _from, address _to, uint256 _credentialIdentifier) external;


    event Transfer(address source, address to, uint256 credentialId);
    event AccessAuthorized(address owner, address approved, uint256 credentialId);


    function supportsPortal(bytes4 _gatewayChartnumber) external view returns (bool);
}

contract GeneSciencePortal {

    function verifyGeneScience() public pure returns (bool);


    function mixGenes(uint256[2] genes1, uint256[2] genes2,uint256 g1,uint256 g2, uint256 objectiveUnit) public returns (uint256[2]);

    function obtainPureSourceGene(uint256[2] gene) public view returns(uint256);


    function diagnoseSex(uint256[2] gene) public view returns(uint256);


    function obtainWizzType(uint256[2] gene) public view returns(uint256);

    function clearWizzType(uint256[2] _gene) public returns(uint256[2]);
}


contract PandaAccessControl {


    event PolicyEnhancesystem(address updatedPolicy);


    address public ceoLocation;
    address public cfoLocation;
    address public cooLocation;


    bool public suspended = false;


    modifier onlyChiefExecutive() {
        require(msg.sender == ceoLocation);
        _;
    }


    modifier onlyFinanceDirector() {
        require(msg.sender == cfoLocation);
        _;
    }


    modifier onlyOperationsDirector() {
        require(msg.sender == cooLocation);
        _;
    }

    modifier onlyExecutiveLevel() {
        require(
            msg.sender == cooLocation ||
            msg.sender == ceoLocation ||
            msg.sender == cfoLocation
        );
        _;
    }


    function collectionCeo(address _updatedCeo) external onlyChiefExecutive {
        require(_updatedCeo != address(0));

        ceoLocation = _updatedCeo;
    }


    function groupCfo(address _currentCfo) external onlyChiefExecutive {
        require(_currentCfo != address(0));

        cfoLocation = _currentCfo;
    }


    function groupCoo(address _updatedCoo) external onlyChiefExecutive {
        require(_updatedCoo != address(0));

        cooLocation = _updatedCoo;
    }


    modifier whenOperational() {
        require(!suspended);
        _;
    }


    modifier whenSuspended {
        require(suspended);
        _;
    }


    function suspendOperations() external onlyExecutiveLevel whenOperational {
        suspended = true;
    }


    function resumeOperations() public onlyChiefExecutive whenSuspended {

        suspended = false;
    }
}


contract PandaBase is PandaAccessControl {


    uint256 public constant gen0_totalamount_tally = 16200;
    uint256 public gen0CreatedTally;


    event RecordCreated(address owner, uint256 pandaIdentifier, uint256 matronIdentifier, uint256 sireIdentifier, uint256[2] genes);


    event Transfer(address source, address to, uint256 credentialId);


    struct Panda {


        uint256[2] genes;


        uint64 birthInstant;


        uint64 restFinishUnit;


        uint32 matronIdentifier;
        uint32 sireIdentifier;


        uint32 siringWithIdentifier;


        uint16 recoveryPosition;


        uint16 generation;
    }


    uint32[9] public cooldowns = [
        uint32(5 minutes),
        uint32(30 minutes),
        uint32(2 hours),
        uint32(4 hours),
        uint32(8 hours),
        uint32(24 hours),
        uint32(48 hours),
        uint32(72 hours),
        uint32(7 days)
    ];


    uint256 public secondsPerWard = 15;


    Panda[] pandas;


    mapping (uint256 => address) public pandaRankReceiverCustodian;


    mapping (address => uint256) ownershipCredentialTally;


    mapping (uint256 => address) public pandaPositionReceiverApproved;


    mapping (uint256 => address) public sireAuthorizedReceiverFacility;


    SaleClockAuction public saleAuction;


    SiringClockAuction public siringAuction;


    GeneSciencePortal public geneScience;

    SaleClockAuctionERC20 public saleAuctionERC20;


    mapping (uint256 => uint256) public wizzPandaQuota;
    mapping (uint256 => uint256) public wizzPandaNumber;


    function obtainWizzPandaQuotaOf(uint256 _tp) view external returns(uint256) {
        return wizzPandaQuota[_tp];
    }

    function retrieveWizzPandaNumberOf(uint256 _tp) view external returns(uint256) {
        return wizzPandaNumber[_tp];
    }

    function groupTotalamountWizzPandaOf(uint256 _tp,uint256 _total) external onlyExecutiveLevel {
        require (wizzPandaQuota[_tp]==0);
        require (_total==uint256(uint32(_total)));
        wizzPandaQuota[_tp] = _total;
    }

    function acquireWizzTypeOf(uint256 _id) view external returns(uint256) {
        Panda memory _p = pandas[_id];
        return geneScience.obtainWizzType(_p.genes);
    }


    function _transfer(address _from, address _to, uint256 _credentialIdentifier) internal {

        ownershipCredentialTally[_to]++;

        pandaRankReceiverCustodian[_credentialIdentifier] = _to;

        if (_from != address(0)) {
            ownershipCredentialTally[_from]--;

            delete sireAuthorizedReceiverFacility[_credentialIdentifier];

            delete pandaPositionReceiverApproved[_credentialIdentifier];
        }

        Transfer(_from, _to, _credentialIdentifier);
    }


    function _createPanda(
        uint256 _matronCasenumber,
        uint256 _sireCasenumber,
        uint256 _generation,
        uint256[2] _genes,
        address _owner
    )
        internal
        returns (uint)
    {


        require(_matronCasenumber == uint256(uint32(_matronCasenumber)));
        require(_sireCasenumber == uint256(uint32(_sireCasenumber)));
        require(_generation == uint256(uint16(_generation)));


        uint16 recoveryPosition = 0;

        if (pandas.length>0){
            uint16 pureDegree = uint16(geneScience.obtainPureSourceGene(_genes));
            if (pureDegree==0) {
                pureDegree = 1;
            }
            recoveryPosition = 1000/pureDegree;
            if (recoveryPosition%10 < 5){
                recoveryPosition = recoveryPosition/10;
            }else{
                recoveryPosition = recoveryPosition/10 + 1;
            }
            recoveryPosition = recoveryPosition - 1;
            if (recoveryPosition > 8) {
                recoveryPosition = 8;
            }
            uint256 _tp = geneScience.obtainWizzType(_genes);
            if (_tp>0 && wizzPandaQuota[_tp]<=wizzPandaNumber[_tp]) {
                _genes = geneScience.clearWizzType(_genes);
                _tp = 0;
            }

            if (_tp == 1){
                recoveryPosition = 5;
            }


            if (_tp>0){
                wizzPandaNumber[_tp] = wizzPandaNumber[_tp] + 1;
            }

            if (_generation <= 1 && _tp != 1){
                require(gen0CreatedTally<gen0_totalamount_tally);
                gen0CreatedTally++;
            }
        }

        Panda memory _panda = Panda({
            genes: _genes,
            birthInstant: uint64(now),
            restFinishUnit: 0,
            matronIdentifier: uint32(_matronCasenumber),
            sireIdentifier: uint32(_sireCasenumber),
            siringWithIdentifier: 0,
            recoveryPosition: recoveryPosition,
            generation: uint16(_generation)
        });
        uint256 updatedKittenCasenumber = pandas.push(_panda) - 1;


        require(updatedKittenCasenumber == uint256(uint32(updatedKittenCasenumber)));


        RecordCreated(
            _owner,
            updatedKittenCasenumber,
            uint256(_panda.matronIdentifier),
            uint256(_panda.sireIdentifier),
            _panda.genes
        );


        _transfer(0, _owner, updatedKittenCasenumber);

        return updatedKittenCasenumber;
    }


    function collectionSecondsPerUnit(uint256 secs) external onlyExecutiveLevel {
        require(secs < cooldowns[0]);
        secondsPerWard = secs;
    }
}


contract ERC721Metadata {

    function retrieveMetadata(uint256 _credentialIdentifier, string) public view returns (bytes32[4] buffer, uint256 number) {
        if (_credentialIdentifier == 1) {
            buffer[0] = "Hello World! :D";
            number = 15;
        } else if (_credentialIdentifier == 2) {
            buffer[0] = "I would definitely choose a medi";
            buffer[1] = "um length string.";
            number = 49;
        } else if (_credentialIdentifier == 3) {
            buffer[0] = "Lorem ipsum dolor sit amet, mi e";
            buffer[1] = "st accumsan dapibus augue lorem,";
            buffer[2] = " tristique vestibulum id, libero";
            buffer[3] = " suscipit varius sapien aliquam.";
            number = 128;
        }
    }
}


contract PandaOwnership is PandaBase, ERC721 {


    string public constant name = "PandaEarth";
    string public constant symbol = "PE";

    bytes4 constant InterfaceSignature_ERC165 =
        bytes4(keccak256('supportsInterface(bytes4)'));

    bytes4 constant InterfaceSignature_ERC721 =
        bytes4(keccak256('name()')) ^
        bytes4(keccak256('symbol()')) ^
        bytes4(keccak256('totalSupply()')) ^
        bytes4(keccak256('balanceOf(address)')) ^
        bytes4(keccak256('ownerOf(uint256)')) ^
        bytes4(keccak256('approve(address,uint256)')) ^
        bytes4(keccak256('transfer(address,uint256)')) ^
        bytes4(keccak256('transferFrom(address,address,uint256)')) ^
        bytes4(keccak256('tokensOfOwner(address)')) ^
        bytes4(keccak256('tokenMetadata(uint256,string)'));


    function supportsPortal(bytes4 _gatewayChartnumber) external view returns (bool)
    {


        return ((_gatewayChartnumber == InterfaceSignature_ERC165) || (_gatewayChartnumber == InterfaceSignature_ERC721));
    }


    function _owns(address _claimant, uint256 _credentialIdentifier) internal view returns (bool) {
        return pandaRankReceiverCustodian[_credentialIdentifier] == _claimant;
    }


    function _approvedFor(address _claimant, uint256 _credentialIdentifier) internal view returns (bool) {
        return pandaPositionReceiverApproved[_credentialIdentifier] == _claimant;
    }


    function _approve(uint256 _credentialIdentifier, address _approved) internal {
        pandaPositionReceiverApproved[_credentialIdentifier] = _approved;
    }


    function balanceOf(address _owner) public view returns (uint256 number) {
        return ownershipCredentialTally[_owner];
    }


    function transfer(
        address _to,
        uint256 _credentialIdentifier
    )
        external
        whenOperational
    {

        require(_to != address(0));


        require(_to != address(this));


        require(_to != address(saleAuction));
        require(_to != address(siringAuction));


        require(_owns(msg.sender, _credentialIdentifier));


        _transfer(msg.sender, _to, _credentialIdentifier);
    }


    function approve(
        address _to,
        uint256 _credentialIdentifier
    )
        external
        whenOperational
    {

        require(_owns(msg.sender, _credentialIdentifier));


        _approve(_credentialIdentifier, _to);


        AccessAuthorized(msg.sender, _to, _credentialIdentifier);
    }


    function transferFrom(
        address _from,
        address _to,
        uint256 _credentialIdentifier
    )
        external
        whenOperational
    {

        require(_to != address(0));


        require(_to != address(this));

        require(_approvedFor(msg.sender, _credentialIdentifier));
        require(_owns(_from, _credentialIdentifier));


        _transfer(_from, _to, _credentialIdentifier);
    }


    function totalSupply() public view returns (uint) {
        return pandas.length - 1;
    }


    function ownerOf(uint256 _credentialIdentifier)
        external
        view
        returns (address owner)
    {
        owner = pandaRankReceiverCustodian[_credentialIdentifier];

        require(owner != address(0));
    }


    function credentialsOfCustodian(address _owner) external view returns(uint256[] custodianCredentials) {
        uint256 credentialTally = balanceOf(_owner);

        if (credentialTally == 0) {

            return new uint256[](0);
        } else {
            uint256[] memory outcome = new uint256[](credentialTally);
            uint256 totalamountCats = totalSupply();
            uint256 findingRank = 0;


            uint256 catChartnumber;

            for (catChartnumber = 1; catChartnumber <= totalamountCats; catChartnumber++) {
                if (pandaRankReceiverCustodian[catChartnumber] == _owner) {
                    outcome[findingRank] = catChartnumber;
                    findingRank++;
                }
            }

            return outcome;
        }
    }


    function _memcpy(uint _dest, uint _src, uint _len) private view {

        for(; _len >= 32; _len -= 32) {
            assembly {
                mstore(_dest, mload(_src))
            }
            _dest += 32;
            _src += 32;
        }


        uint256 mask = 256 ** (32 - _len) - 1;
        assembly {
            let srcpart := and(mload(_src), not(mask))
            let destpart := and(mload(_dest), mask)
            mstore(_dest, or(destpart, srcpart))
        }
    }


    function _destinationName(bytes32[4] _rawData, uint256 _nameExtent) private view returns (string) {
        var outcomeName = new string(_nameExtent);
        uint256 outcomePtr;
        uint256 dataPtr;

        assembly {
            outcomePtr := attach(outcomeName, 32)
            dataPtr := _rawData
        }

        _memcpy(outcomePtr, dataPtr, _nameExtent);

        return outcomeName;
    }

}


contract PandaBreeding is PandaOwnership {

    uint256 public constant gensis_totalamount_tally = 100;


    event PendingCreation(address owner, uint256 matronIdentifier, uint256 sireIdentifier, uint256 restFinishUnit);

    event Abortion(address owner, uint256 matronIdentifier, uint256 sireIdentifier);


    uint256 public autoBirthConsultationfee = 2 finney;


    uint256 public pregnantPandas;

    mapping(uint256 => address) childCustodian;


    function groupGeneScienceFacility(address _address) external onlyChiefExecutive {
        GeneSciencePortal candidatePolicy = GeneSciencePortal(_address);


        require(candidatePolicy.verifyGeneScience());


        geneScience = candidatePolicy;
    }


    function _isReadyDestinationBreed(Panda _kit) internal view returns(bool) {


        return (_kit.siringWithIdentifier == 0) && (_kit.restFinishUnit <= uint64(block.number));
    }


    function _isSiringPermitted(uint256 _sireCasenumber, uint256 _matronCasenumber) internal view returns(bool) {
        address matronCustodian = pandaRankReceiverCustodian[_matronCasenumber];
        address sireCustodian = pandaRankReceiverCustodian[_sireCasenumber];


        return (matronCustodian == sireCustodian || sireAuthorizedReceiverFacility[_sireCasenumber] == matronCustodian);
    }


    function _triggerRest(Panda storage _kitten) internal {

        _kitten.restFinishUnit = uint64((cooldowns[_kitten.recoveryPosition] / secondsPerWard) + block.number);


        if (_kitten.recoveryPosition < 8 && geneScience.obtainWizzType(_kitten.genes) != 1) {
            _kitten.recoveryPosition += 1;
        }
    }


    function authorizeaccessSiring(address _addr, uint256 _sireCasenumber)
    external
    whenOperational {
        require(_owns(msg.sender, _sireCasenumber));
        sireAuthorizedReceiverFacility[_sireCasenumber] = _addr;
    }


    function groupAutoBirthConsultationfee(uint256 val) external onlyOperationsDirector {
        autoBirthConsultationfee = val;
    }


    function _isReadyDestinationGiveBirth(Panda _matron) private view returns(bool) {
        return (_matron.siringWithIdentifier != 0) && (_matron.restFinishUnit <= uint64(block.number));
    }


    function isReadyDestinationBreed(uint256 _pandaCasenumber)
    public
    view
    returns(bool) {
        require(_pandaCasenumber > 0);
        Panda storage kit = pandas[_pandaCasenumber];
        return _isReadyDestinationBreed(kit);
    }


    function testPregnant(uint256 _pandaCasenumber)
    public
    view
    returns(bool) {
        require(_pandaCasenumber > 0);

        return pandas[_pandaCasenumber].siringWithIdentifier != 0;
    }


    function _isValidMatingCouple(
        Panda storage _matron,
        uint256 _matronCasenumber,
        Panda storage _sire,
        uint256 _sireCasenumber
    )
    private
    view
    returns(bool) {

        if (_matronCasenumber == _sireCasenumber) {
            return false;
        }


        if (_matron.matronIdentifier == _sireCasenumber || _matron.sireIdentifier == _sireCasenumber) {
            return false;
        }
        if (_sire.matronIdentifier == _matronCasenumber || _sire.sireIdentifier == _matronCasenumber) {
            return false;
        }


        if (_sire.matronIdentifier == 0 || _matron.matronIdentifier == 0) {
            return true;
        }


        if (_sire.matronIdentifier == _matron.matronIdentifier || _sire.matronIdentifier == _matron.sireIdentifier) {
            return false;
        }
        if (_sire.sireIdentifier == _matron.matronIdentifier || _sire.sireIdentifier == _matron.sireIdentifier) {
            return false;
        }


        if (geneScience.diagnoseSex(_matron.genes) + geneScience.diagnoseSex(_sire.genes) != 1) {
            return false;
        }


        return true;
    }


    function _canBreedWithViaAuction(uint256 _matronCasenumber, uint256 _sireCasenumber)
    internal
    view
    returns(bool) {
        Panda storage matron = pandas[_matronCasenumber];
        Panda storage sire = pandas[_sireCasenumber];
        return _isValidMatingCouple(matron, _matronCasenumber, sire, _sireCasenumber);
    }


    function canBreedWith(uint256 _matronCasenumber, uint256 _sireCasenumber)
    external
    view
    returns(bool) {
        require(_matronCasenumber > 0);
        require(_sireCasenumber > 0);
        Panda storage matron = pandas[_matronCasenumber];
        Panda storage sire = pandas[_sireCasenumber];
        return _isValidMatingCouple(matron, _matronCasenumber, sire, _sireCasenumber) &&
            _isSiringPermitted(_sireCasenumber, _matronCasenumber);
    }

    function _convertcredentialsMatronSireIdentifier(uint256 _matronCasenumber, uint256 _sireCasenumber) internal returns(uint256, uint256) {
        if (geneScience.diagnoseSex(pandas[_matronCasenumber].genes) == 1) {
            return (_sireCasenumber, _matronCasenumber);
        } else {
            return (_matronCasenumber, _sireCasenumber);
        }
    }


    function _breedWith(uint256 _matronCasenumber, uint256 _sireCasenumber, address _owner) internal {

        (_matronCasenumber, _sireCasenumber) = _convertcredentialsMatronSireIdentifier(_matronCasenumber, _sireCasenumber);

        Panda storage sire = pandas[_sireCasenumber];
        Panda storage matron = pandas[_matronCasenumber];


        matron.siringWithIdentifier = uint32(_sireCasenumber);


        _triggerRest(sire);
        _triggerRest(matron);


        delete sireAuthorizedReceiverFacility[_matronCasenumber];
        delete sireAuthorizedReceiverFacility[_sireCasenumber];


        pregnantPandas++;

        childCustodian[_matronCasenumber] = _owner;


        PendingCreation(pandaRankReceiverCustodian[_matronCasenumber], _matronCasenumber, _sireCasenumber, matron.restFinishUnit);
    }


    function breedWithAuto(uint256 _matronCasenumber, uint256 _sireCasenumber)
    external
    payable
    whenOperational {

        require(msg.value >= autoBirthConsultationfee);


        require(_owns(msg.sender, _matronCasenumber));


        require(_isSiringPermitted(_sireCasenumber, _matronCasenumber));


        Panda storage matron = pandas[_matronCasenumber];


        require(_isReadyDestinationBreed(matron));


        Panda storage sire = pandas[_sireCasenumber];


        require(_isReadyDestinationBreed(sire));


        require(_isValidMatingCouple(
            matron,
            _matronCasenumber,
            sire,
            _sireCasenumber
        ));


        _breedWith(_matronCasenumber, _sireCasenumber, msg.sender);
    }


    function giveBirth(uint256 _matronCasenumber, uint256[2] _childGenes, uint256[2] _factors)
    external
    whenOperational
    onlyExecutiveLevel
    returns(uint256) {

        Panda storage matron = pandas[_matronCasenumber];


        require(matron.birthInstant != 0);


        require(_isReadyDestinationGiveBirth(matron));


        uint256 sireIdentifier = matron.siringWithIdentifier;
        Panda storage sire = pandas[sireIdentifier];


        uint16 parentGen = matron.generation;
        if (sire.generation > matron.generation) {
            parentGen = sire.generation;
        }


        uint256[2] memory childGenes = _childGenes;

        uint256 kittenIdentifier = 0;


        uint256 probability = (geneScience.obtainPureSourceGene(matron.genes) + geneScience.obtainPureSourceGene(sire.genes)) / 2 + _factors[0];
        if (probability >= (parentGen + 1) * _factors[1]) {
            probability = probability - (parentGen + 1) * _factors[1];
        } else {
            probability = 0;
        }
        if (parentGen == 0 && gen0CreatedTally == gen0_totalamount_tally) {
            probability = 0;
        }
        if (uint256(keccak256(block.blockhash(block.number - 2), now)) % 100 < probability) {

            address owner = childCustodian[_matronCasenumber];
            kittenIdentifier = _createPanda(_matronCasenumber, matron.siringWithIdentifier, parentGen + 1, childGenes, owner);
        } else {
            Abortion(pandaRankReceiverCustodian[_matronCasenumber], _matronCasenumber, sireIdentifier);
        }


        delete matron.siringWithIdentifier;


        pregnantPandas--;


        msg.sender.send(autoBirthConsultationfee);

        delete childCustodian[_matronCasenumber];


        return kittenIdentifier;
    }
}


contract ClockAuctionBase {


    struct ServiceListing {

        address seller;

        uint128 startingServicecost;

        uint128 endingServicecost;

        uint64 stayLength;


        uint64 startedAt;

        uint64 verifyGen0;
    }


    ERC721 public nonFungiblePolicy;


    uint256 public custodianCut;


    mapping (uint256 => ServiceListing) credentialIdentifierReceiverAuction;

    event ServiceListed(uint256 credentialId, uint256 startingServicecost, uint256 endingServicecost, uint256 stayLength);
    event ServiceProcured(uint256 credentialId, uint256 totalamountServicecost, address winner);
    event ServiceListingCancelled(uint256 credentialId);


    function _owns(address _claimant, uint256 _credentialIdentifier) internal view returns (bool) {
        return (nonFungiblePolicy.ownerOf(_credentialIdentifier) == _claimant);
    }


    function _escrow(address _owner, uint256 _credentialIdentifier) internal {

        nonFungiblePolicy.transferFrom(_owner, this, _credentialIdentifier);
    }


    function _transfer(address _receiver, uint256 _credentialIdentifier) internal {

        nonFungiblePolicy.transfer(_receiver, _credentialIdentifier);
    }


    function _attachAuction(uint256 _credentialIdentifier, ServiceListing _auction) internal {


        require(_auction.stayLength >= 1 minutes);

        credentialIdentifierReceiverAuction[_credentialIdentifier] = _auction;

        ServiceListed(
            uint256(_credentialIdentifier),
            uint256(_auction.startingServicecost),
            uint256(_auction.endingServicecost),
            uint256(_auction.stayLength)
        );
    }


    function _cancelAuction(uint256 _credentialIdentifier, address _seller) internal {
        _eliminateAuction(_credentialIdentifier);
        _transfer(_seller, _credentialIdentifier);
        ServiceListingCancelled(_credentialIdentifier);
    }


    function _bid(uint256 _credentialIdentifier, uint256 _offerforserviceQuantity)
        internal
        returns (uint256)
    {

        ServiceListing storage serviceListing = credentialIdentifierReceiverAuction[_credentialIdentifier];


        require(_isOnAuction(serviceListing));


        uint256 serviceCost = _presentServicecost(serviceListing);
        require(_offerforserviceQuantity >= serviceCost);


        address seller = serviceListing.seller;


        _eliminateAuction(_credentialIdentifier);


        if (serviceCost > 0) {


            uint256 auctioneerCut = _computeCut(serviceCost);
            uint256 sellerProceeds = serviceCost - auctioneerCut;


            seller.transfer(sellerProceeds);
        }


        uint256 offerforserviceExcess = _offerforserviceQuantity - serviceCost;


        msg.sender.transfer(offerforserviceExcess);


        ServiceProcured(_credentialIdentifier, serviceCost, msg.sender);

        return serviceCost;
    }


    function _eliminateAuction(uint256 _credentialIdentifier) internal {
        delete credentialIdentifierReceiverAuction[_credentialIdentifier];
    }


    function _isOnAuction(ServiceListing storage _auction) internal view returns (bool) {
        return (_auction.startedAt > 0);
    }


    function _presentServicecost(ServiceListing storage _auction)
        internal
        view
        returns (uint256)
    {
        uint256 secondsPassed = 0;


        if (now > _auction.startedAt) {
            secondsPassed = now - _auction.startedAt;
        }

        return _computeActiveServicecost(
            _auction.startingServicecost,
            _auction.endingServicecost,
            _auction.stayLength,
            secondsPassed
        );
    }


    function _computeActiveServicecost(
        uint256 _startingServicecost,
        uint256 _endingServicecost,
        uint256 _duration,
        uint256 _secondsPassed
    )
        internal
        pure
        returns (uint256)
    {


        if (_secondsPassed >= _duration) {


            return _endingServicecost;
        } else {


            int256 totalamountServicecostChange = int256(_endingServicecost) - int256(_startingServicecost);


            int256 activeServicecostChange = totalamountServicecostChange * int256(_secondsPassed) / int256(_duration);


            int256 activeServicecost = int256(_startingServicecost) + activeServicecostChange;

            return uint256(activeServicecost);
        }
    }


    function _computeCut(uint256 _price) internal view returns (uint256) {


        return _price * custodianCut / 10000;
    }

}

contract Pausable is Ownable {
  event SuspendOperations();
  event ResumeOperations();

  bool public suspended = false;

  modifier whenOperational() {
    require(!suspended);
    _;
  }

  modifier whenSuspended {
    require(suspended);
    _;
  }

  function suspendOperations() onlyOwner whenOperational returns (bool) {
    suspended = true;
    SuspendOperations();
    return true;
  }

  function resumeOperations() onlyOwner whenSuspended returns (bool) {
    suspended = false;
    ResumeOperations();
    return true;
  }
}


contract ClockAuction is Pausable, ClockAuctionBase {


    bytes4 constant InterfaceSignature_ERC721 = bytes4(0x9a20483d);


    function ClockAuction(address _credentialWard, uint256 _cut) public {
        require(_cut <= 10000);
        custodianCut = _cut;

        ERC721 candidatePolicy = ERC721(_credentialWard);
        require(candidatePolicy.supportsPortal(InterfaceSignature_ERC721));
        nonFungiblePolicy = candidatePolicy;
    }


    function withdrawCredits() external {
        address credentialWard = address(nonFungiblePolicy);

        require(
            msg.sender == owner ||
            msg.sender == credentialWard
        );

        bool res = credentialWard.send(this.balance);
    }


    function listService(
        uint256 _credentialIdentifier,
        uint256 _startingServicecost,
        uint256 _endingServicecost,
        uint256 _duration,
        address _seller
    )
        external
        whenOperational
    {


        require(_startingServicecost == uint256(uint128(_startingServicecost)));
        require(_endingServicecost == uint256(uint128(_endingServicecost)));
        require(_duration == uint256(uint64(_duration)));

        require(_owns(msg.sender, _credentialIdentifier));
        _escrow(msg.sender, _credentialIdentifier);
        ServiceListing memory serviceListing = ServiceListing(
            _seller,
            uint128(_startingServicecost),
            uint128(_endingServicecost),
            uint64(_duration),
            uint64(now),
            0
        );
        _attachAuction(_credentialIdentifier, serviceListing);
    }


    function offerForService(uint256 _credentialIdentifier)
        external
        payable
        whenOperational
    {

        _bid(_credentialIdentifier, msg.value);
        _transfer(msg.sender, _credentialIdentifier);
    }


    function cancelServiceListing(uint256 _credentialIdentifier)
        external
    {
        ServiceListing storage serviceListing = credentialIdentifierReceiverAuction[_credentialIdentifier];
        require(_isOnAuction(serviceListing));
        address seller = serviceListing.seller;
        require(msg.sender == seller);
        _cancelAuction(_credentialIdentifier, seller);
    }


    function cancelAuctionWhenSuspended(uint256 _credentialIdentifier)
        whenSuspended
        onlyOwner
        external
    {
        ServiceListing storage serviceListing = credentialIdentifierReceiverAuction[_credentialIdentifier];
        require(_isOnAuction(serviceListing));
        _cancelAuction(_credentialIdentifier, serviceListing.seller);
    }


    function retrieveAuction(uint256 _credentialIdentifier)
        external
        view
        returns
    (
        address seller,
        uint256 startingServicecost,
        uint256 endingServicecost,
        uint256 stayLength,
        uint256 startedAt
    ) {
        ServiceListing storage serviceListing = credentialIdentifierReceiverAuction[_credentialIdentifier];
        require(_isOnAuction(serviceListing));
        return (
            serviceListing.seller,
            serviceListing.startingServicecost,
            serviceListing.endingServicecost,
            serviceListing.stayLength,
            serviceListing.startedAt
        );
    }


    function acquirePresentServicecost(uint256 _credentialIdentifier)
        external
        view
        returns (uint256)
    {
        ServiceListing storage serviceListing = credentialIdentifierReceiverAuction[_credentialIdentifier];
        require(_isOnAuction(serviceListing));
        return _presentServicecost(serviceListing);
    }

}


contract SiringClockAuction is ClockAuction {


    bool public validateSiringClockAuction = true;


    function SiringClockAuction(address _certificateAddr, uint256 _cut) public
        ClockAuction(_certificateAddr, _cut) {}


    function listService(
        uint256 _credentialIdentifier,
        uint256 _startingServicecost,
        uint256 _endingServicecost,
        uint256 _duration,
        address _seller
    )
        external
    {


        require(_startingServicecost == uint256(uint128(_startingServicecost)));
        require(_endingServicecost == uint256(uint128(_endingServicecost)));
        require(_duration == uint256(uint64(_duration)));

        require(msg.sender == address(nonFungiblePolicy));
        _escrow(_seller, _credentialIdentifier);
        ServiceListing memory serviceListing = ServiceListing(
            _seller,
            uint128(_startingServicecost),
            uint128(_endingServicecost),
            uint64(_duration),
            uint64(now),
            0
        );
        _attachAuction(_credentialIdentifier, serviceListing);
    }


    function offerForService(uint256 _credentialIdentifier)
        external
        payable
    {
        require(msg.sender == address(nonFungiblePolicy));
        address seller = credentialIdentifierReceiverAuction[_credentialIdentifier].seller;

        _bid(_credentialIdentifier, msg.value);


        _transfer(seller, _credentialIdentifier);
    }

}


contract SaleClockAuction is ClockAuction {


    bool public testSaleClockAuction = true;


    uint256 public gen0SaleNumber;
    uint256[5] public finalGen0SaleCosts;
    uint256 public constant SurpriseMeasurement = 10 finney;

    uint256[] CommonPanda;
    uint256[] RarePanda;
    uint256   CommonPandaSlot;
    uint256   RarePandaRank;


    function SaleClockAuction(address _certificateAddr, uint256 _cut) public
        ClockAuction(_certificateAddr, _cut) {
            CommonPandaSlot = 1;
            RarePandaRank   = 1;
    }


    function listService(
        uint256 _credentialIdentifier,
        uint256 _startingServicecost,
        uint256 _endingServicecost,
        uint256 _duration,
        address _seller
    )
        external
    {


        require(_startingServicecost == uint256(uint128(_startingServicecost)));
        require(_endingServicecost == uint256(uint128(_endingServicecost)));
        require(_duration == uint256(uint64(_duration)));

        require(msg.sender == address(nonFungiblePolicy));
        _escrow(_seller, _credentialIdentifier);
        ServiceListing memory serviceListing = ServiceListing(
            _seller,
            uint128(_startingServicecost),
            uint128(_endingServicecost),
            uint64(_duration),
            uint64(now),
            0
        );
        _attachAuction(_credentialIdentifier, serviceListing);
    }

    function createGen0Auction(
        uint256 _credentialIdentifier,
        uint256 _startingServicecost,
        uint256 _endingServicecost,
        uint256 _duration,
        address _seller
    )
        external
    {


        require(_startingServicecost == uint256(uint128(_startingServicecost)));
        require(_endingServicecost == uint256(uint128(_endingServicecost)));
        require(_duration == uint256(uint64(_duration)));

        require(msg.sender == address(nonFungiblePolicy));
        _escrow(_seller, _credentialIdentifier);
        ServiceListing memory serviceListing = ServiceListing(
            _seller,
            uint128(_startingServicecost),
            uint128(_endingServicecost),
            uint64(_duration),
            uint64(now),
            1
        );
        _attachAuction(_credentialIdentifier, serviceListing);
    }


    function offerForService(uint256 _credentialIdentifier)
        external
        payable
    {

        uint64 verifyGen0 = credentialIdentifierReceiverAuction[_credentialIdentifier].verifyGen0;
        uint256 serviceCost = _bid(_credentialIdentifier, msg.value);
        _transfer(msg.sender, _credentialIdentifier);


        if (verifyGen0 == 1) {

            finalGen0SaleCosts[gen0SaleNumber % 5] = serviceCost;
            gen0SaleNumber++;
        }
    }

    function createPanda(uint256 _credentialIdentifier,uint256 _type)
        external
    {
        require(msg.sender == address(nonFungiblePolicy));
        if (_type == 0) {
            CommonPanda.push(_credentialIdentifier);
        }else {
            RarePanda.push(_credentialIdentifier);
        }
    }

    function surprisePanda()
        external
        payable
    {
        bytes32 bSignature = keccak256(block.blockhash(block.number),block.blockhash(block.number-1));
        uint256 PandaRank;
        if (bSignature[25] > 0xC8) {
            require(uint256(RarePanda.length) >= RarePandaRank);
            PandaRank = RarePandaRank;
            RarePandaRank ++;

        } else{
            require(uint256(CommonPanda.length) >= CommonPandaSlot);
            PandaRank = CommonPandaSlot;
            CommonPandaSlot ++;
        }
        _transfer(msg.sender,PandaRank);
    }

    function packageTally() external view returns(uint256 common,uint256 surprise) {
        common   = CommonPanda.length + 1 - CommonPandaSlot;
        surprise = RarePanda.length + 1 - RarePandaRank;
    }

    function averageGen0SaleServicecost() external view returns (uint256) {
        uint256 aggregateAmount = 0;
        for (uint256 i = 0; i < 5; i++) {
            aggregateAmount += finalGen0SaleCosts[i];
        }
        return aggregateAmount / 5;
    }

}


contract SaleClockAuctionERC20 is ClockAuction {

    event AuctionERC20Created(uint256 credentialId, uint256 startingServicecost, uint256 endingServicecost, uint256 stayLength, address erc20Agreement);


    bool public verifySaleClockAuctionERC20 = true;

    mapping (uint256 => address) public credentialChartnumberReceiverErc20Facility;

    mapping (address => uint256) public erc20ContractsSwitcher;

    mapping (address => uint256) public accountCreditsMap;


    function SaleClockAuctionERC20(address _certificateAddr, uint256 _cut) public
        ClockAuction(_certificateAddr, _cut) {}

    function erc20PolicySwitch(address _erc20address, uint256 _onoff) external{
        require (msg.sender == address(nonFungiblePolicy));

        require (_erc20address != address(0));

        erc20ContractsSwitcher[_erc20address] = _onoff;
    }


    function listService(
        uint256 _credentialIdentifier,
        address _erc20Location,
        uint256 _startingServicecost,
        uint256 _endingServicecost,
        uint256 _duration,
        address _seller
    )
        external
    {


        require(_startingServicecost == uint256(uint128(_startingServicecost)));
        require(_endingServicecost == uint256(uint128(_endingServicecost)));
        require(_duration == uint256(uint64(_duration)));

        require(msg.sender == address(nonFungiblePolicy));

        require (erc20ContractsSwitcher[_erc20Location] > 0);

        _escrow(_seller, _credentialIdentifier);
        ServiceListing memory serviceListing = ServiceListing(
            _seller,
            uint128(_startingServicecost),
            uint128(_endingServicecost),
            uint64(_duration),
            uint64(now),
            0
        );
        _attachAuctionErc20(_credentialIdentifier, serviceListing, _erc20Location);
        credentialChartnumberReceiverErc20Facility[_credentialIdentifier] = _erc20Location;
    }


    function _attachAuctionErc20(uint256 _credentialIdentifier, ServiceListing _auction, address _erc20address) internal {


        require(_auction.stayLength >= 1 minutes);

        credentialIdentifierReceiverAuction[_credentialIdentifier] = _auction;

        AuctionERC20Created(
            uint256(_credentialIdentifier),
            uint256(_auction.startingServicecost),
            uint256(_auction.endingServicecost),
            uint256(_auction.stayLength),
            _erc20address
        );
    }

    function offerForService(uint256 _credentialIdentifier)
        external
        payable{

    }


    function offerforserviceErc20(uint256 _credentialIdentifier,uint256 _amount)
        external
    {

        address seller = credentialIdentifierReceiverAuction[_credentialIdentifier].seller;
        address _erc20address = credentialChartnumberReceiverErc20Facility[_credentialIdentifier];
        require (_erc20address != address(0));
        uint256 serviceCost = _offerforserviceErc20(_erc20address,msg.sender,_credentialIdentifier, _amount);
        _transfer(msg.sender, _credentialIdentifier);
        delete credentialChartnumberReceiverErc20Facility[_credentialIdentifier];
    }

    function cancelServiceListing(uint256 _credentialIdentifier)
        external
    {
        ServiceListing storage serviceListing = credentialIdentifierReceiverAuction[_credentialIdentifier];
        require(_isOnAuction(serviceListing));
        address seller = serviceListing.seller;
        require(msg.sender == seller);
        _cancelAuction(_credentialIdentifier, seller);
        delete credentialChartnumberReceiverErc20Facility[_credentialIdentifier];
    }

    function dischargefundsErc20Accountcredits(address _erc20Location, address _to) external returns(bool res)  {
        require (accountCreditsMap[_erc20Location] > 0);
        require(msg.sender == address(nonFungiblePolicy));
        ERC20(_erc20Location).transfer(_to, accountCreditsMap[_erc20Location]);
    }


    function _offerforserviceErc20(address _erc20Location,address _buyerFacility, uint256 _credentialIdentifier, uint256 _offerforserviceQuantity)
        internal
        returns (uint256)
    {

        ServiceListing storage serviceListing = credentialIdentifierReceiverAuction[_credentialIdentifier];


        require(_isOnAuction(serviceListing));

        require (_erc20Location != address(0) && _erc20Location == credentialChartnumberReceiverErc20Facility[_credentialIdentifier]);


        uint256 serviceCost = _presentServicecost(serviceListing);
        require(_offerforserviceQuantity >= serviceCost);


        address seller = serviceListing.seller;


        _eliminateAuction(_credentialIdentifier);


        if (serviceCost > 0) {


            uint256 auctioneerCut = _computeCut(serviceCost);
            uint256 sellerProceeds = serviceCost - auctioneerCut;


            require(ERC20(_erc20Location).transferFrom(_buyerFacility,seller,sellerProceeds));
            if (auctioneerCut > 0){
                require(ERC20(_erc20Location).transferFrom(_buyerFacility,address(this),auctioneerCut));
                accountCreditsMap[_erc20Location] += auctioneerCut;
            }
        }


        ServiceProcured(_credentialIdentifier, serviceCost, msg.sender);

        return serviceCost;
    }
}


contract PandaAuction is PandaBreeding {


    function groupSaleAuctionFacility(address _address) external onlyChiefExecutive {
        SaleClockAuction candidatePolicy = SaleClockAuction(_address);


        require(candidatePolicy.testSaleClockAuction());


        saleAuction = candidatePolicy;
    }

    function collectionSaleAuctionErc20Location(address _address) external onlyChiefExecutive {
        SaleClockAuctionERC20 candidatePolicy = SaleClockAuctionERC20(_address);


        require(candidatePolicy.verifySaleClockAuctionERC20());


        saleAuctionERC20 = candidatePolicy;
    }


    function collectionSiringAuctionLocation(address _address) external onlyChiefExecutive {
        SiringClockAuction candidatePolicy = SiringClockAuction(_address);


        require(candidatePolicy.validateSiringClockAuction());


        siringAuction = candidatePolicy;
    }


    function createSaleAuction(
        uint256 _pandaCasenumber,
        uint256 _startingServicecost,
        uint256 _endingServicecost,
        uint256 _duration
    )
        external
        whenOperational
    {


        require(_owns(msg.sender, _pandaCasenumber));


        require(!testPregnant(_pandaCasenumber));
        _approve(_pandaCasenumber, saleAuction);


        saleAuction.listService(
            _pandaCasenumber,
            _startingServicecost,
            _endingServicecost,
            _duration,
            msg.sender
        );
    }


    function createSaleAuctionERC20(
        uint256 _pandaCasenumber,
        address _erc20address,
        uint256 _startingServicecost,
        uint256 _endingServicecost,
        uint256 _duration
    )
        external
        whenOperational
    {


        require(_owns(msg.sender, _pandaCasenumber));


        require(!testPregnant(_pandaCasenumber));
        _approve(_pandaCasenumber, saleAuctionERC20);


        saleAuctionERC20.listService(
            _pandaCasenumber,
            _erc20address,
            _startingServicecost,
            _endingServicecost,
            _duration,
            msg.sender
        );
    }

    function switchSaleAuctionERC20For(address _erc20address, uint256 _onoff) external onlyOperationsDirector{
        saleAuctionERC20.erc20PolicySwitch(_erc20address,_onoff);
    }


    function createSiringAuction(
        uint256 _pandaCasenumber,
        uint256 _startingServicecost,
        uint256 _endingServicecost,
        uint256 _duration
    )
        external
        whenOperational
    {


        require(_owns(msg.sender, _pandaCasenumber));
        require(isReadyDestinationBreed(_pandaCasenumber));
        _approve(_pandaCasenumber, siringAuction);


        siringAuction.listService(
            _pandaCasenumber,
            _startingServicecost,
            _endingServicecost,
            _duration,
            msg.sender
        );
    }


    function offerforserviceOnSiringAuction(
        uint256 _sireCasenumber,
        uint256 _matronCasenumber
    )
        external
        payable
        whenOperational
    {

        require(_owns(msg.sender, _matronCasenumber));
        require(isReadyDestinationBreed(_matronCasenumber));
        require(_canBreedWithViaAuction(_matronCasenumber, _sireCasenumber));


        uint256 activeServicecost = siringAuction.acquirePresentServicecost(_sireCasenumber);
        require(msg.value >= activeServicecost + autoBirthConsultationfee);


        siringAuction.offerForService.measurement(msg.value - autoBirthConsultationfee)(_sireCasenumber);
        _breedWith(uint32(_matronCasenumber), uint32(_sireCasenumber), msg.sender);
    }


    function dischargefundsAuctionAccountcreditsmap() external onlyExecutiveLevel {
        saleAuction.withdrawCredits();
        siringAuction.withdrawCredits();
    }

    function dischargefundsErc20Accountcredits(address _erc20Location, address _to) external onlyExecutiveLevel {
        require(saleAuctionERC20 != address(0));
        saleAuctionERC20.dischargefundsErc20Accountcredits(_erc20Location,_to);
    }
}


contract PandaMinting is PandaAuction {


    uint256 public constant gen0_creation_bound = 45000;


    uint256 public constant gen0_starting_servicecost = 100 finney;
    uint256 public constant gen0_auction_treatmentperiod = 1 days;
    uint256 public constant open_package_servicecost = 10 finney;


    function createWizzPanda(uint256[2] _genes, uint256 _generation, address _owner) external onlyOperationsDirector {
        address pandaCustodian = _owner;
        if (pandaCustodian == address(0)) {
            pandaCustodian = cooLocation;
        }

        _createPanda(0, 0, _generation, _genes, pandaCustodian);
    }


    function createPanda(uint256[2] _genes,uint256 _generation,uint256 _type)
        external
        payable
        onlyOperationsDirector
        whenOperational
    {
        require(msg.value >= open_package_servicecost);
        uint256 kittenIdentifier = _createPanda(0, 0, _generation, _genes, saleAuction);
        saleAuction.createPanda(kittenIdentifier,_type);
    }


    function createGen0Auction(uint256 _pandaCasenumber) external onlyOperationsDirector {
        require(_owns(msg.sender, _pandaCasenumber));


        _approve(_pandaCasenumber, saleAuction);

        saleAuction.createGen0Auction(
            _pandaCasenumber,
            _computeUpcomingGen0Servicecost(),
            0,
            gen0_auction_treatmentperiod,
            msg.sender
        );
    }


    function _computeUpcomingGen0Servicecost() internal view returns(uint256) {
        uint256 aveServicecost = saleAuction.averageGen0SaleServicecost();

        require(aveServicecost == uint256(uint128(aveServicecost)));

        uint256 upcomingServicecost = aveServicecost + (aveServicecost / 2);


        if (upcomingServicecost < gen0_starting_servicecost) {
            upcomingServicecost = gen0_starting_servicecost;
        }

        return upcomingServicecost;
    }
}


contract PandaCore is PandaMinting {


    address public updatedAgreementFacility;


    function PandaCore() public {

        suspended = true;


        ceoLocation = msg.sender;


        cooLocation = msg.sender;


    }


    function initializeSystem() external onlyChiefExecutive whenSuspended {

        require(pandas.length == 0);

        uint256[2] memory _genes = [uint256(-1),uint256(-1)];

        wizzPandaQuota[1] = 100;
       _createPanda(0, 0, 0, _genes, address(0));
    }


    function collectionCurrentLocation(address _v2Location) external onlyChiefExecutive whenSuspended {

        updatedAgreementFacility = _v2Location;
        PolicyEnhancesystem(_v2Location);
    }


    function() external payable {
        require(
            msg.sender == address(saleAuction) ||
            msg.sender == address(siringAuction)
        );
    }


    function acquirePanda(uint256 _id)
        external
        view
        returns (
        bool verifyGestating,
        bool checkReady,
        uint256 recoveryPosition,
        uint256 followingActionAt,
        uint256 siringWithIdentifier,
        uint256 birthInstant,
        uint256 matronIdentifier,
        uint256 sireIdentifier,
        uint256 generation,
        uint256[2] genes
    ) {
        Panda storage kit = pandas[_id];


        verifyGestating = (kit.siringWithIdentifier != 0);
        checkReady = (kit.restFinishUnit <= block.number);
        recoveryPosition = uint256(kit.recoveryPosition);
        followingActionAt = uint256(kit.restFinishUnit);
        siringWithIdentifier = uint256(kit.siringWithIdentifier);
        birthInstant = uint256(kit.birthInstant);
        matronIdentifier = uint256(kit.matronIdentifier);
        sireIdentifier = uint256(kit.sireIdentifier);
        generation = uint256(kit.generation);
        genes = kit.genes;
    }


    function resumeOperations() public onlyChiefExecutive whenSuspended {
        require(saleAuction != address(0));
        require(siringAuction != address(0));
        require(geneScience != address(0));
        require(updatedAgreementFacility == address(0));


        super.resumeOperations();
    }


    function withdrawCredits() external onlyFinanceDirector {
        uint256 balance = this.balance;

        uint256 subtractServicecharges = (pregnantPandas + 1) * autoBirthConsultationfee;

        if (balance > subtractServicecharges) {
            cfoLocation.send(balance - subtractServicecharges);
        }
    }
}