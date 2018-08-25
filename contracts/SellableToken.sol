pragma solidity 0.4.24;

import "./Autobay.sol";

import "./Multivest.sol";

import "./OraclizeAPI.sol";




contract SellableToken is Multivest, usingOraclize {



    uint256 public constant DECIMALS = 18;



    uint256 public constant PRE_ICO_ID = 0;



    Autobay public autobay;



    uint256 public startTime;



    uint256 public endTime;



    uint256 public maxTokenSupply;

    uint256 public etherPriceInUSD;

    uint256 public soldTokens;



    address[] public investors;



    uint256 public collectedEthers;



    uint256 public priceUpdateAt = block.timestamp;



    address public etherHolder;



    Tier[] public tiers;



    struct Tier {

        uint256 maxAmount;

        uint256 price;

        uint256 startTime;

        uint256 endTime;

    }



    event NewOraclizeQuery(string _description);

    event NewAutobayPriceTicker(string _price);



    constructor(

        address _multivestAddress,

        address _autobay,

        address _etherHolder,

        uint256 _etherPriceInUSD,

        uint256 _maxTokenSupply

    ) public Multivest(_multivestAddress)

    {

        require(_autobay != address(0));

        autobay = Autobay(_autobay);



        // etherHolder = _etherHolder;

        require((_maxTokenSupply == uint256(0)) || (_maxTokenSupply <= autobay.maxSupply()));

        // uint256 etherPriceInUSD;


        etherPriceInUSD = _etherPriceInUSD;
        maxTokenSupply = _maxTokenSupply;



//        oraclize_setNetwork(networkID_auto);

//        oraclize = OraclizeI(OAR.getAddress());

    }



    function setAutobay(address _autobay) public onlyOwner {

        require(_autobay != address(0));

        autobay = Autobay(_autobay);

    }



    // set ether price in USD with 5 digits after the decimal point

    //ex. 308.75000

    //for updating the price through  multivest

    function setEtherInUSD(string _price) public onlyAllowedMultivests(msg.sender) {

        bytes memory bytePrice = bytes(_price);

        uint256 dot = bytePrice.length.sub(uint256(6));
        // uint256 etherPriceInUSD;


        // check if dot is in 6 position  from  the last

        require(0x2e == uint(bytePrice[dot]));



        uint256 newPrice = uint256(10 ** 23).div(parseInt(_price, 5));



        require(newPrice > 0);



        etherPriceInUSD = parseInt(_price, 5);



        priceUpdateAt = block.timestamp;



        emit NewAutobayPriceTicker(_price);

    }



    function setEtherHolder(address _etherHolder) public onlyOwner {

        require(_etherHolder != address(0));

        etherHolder = _etherHolder;

    }



    function isPreICOActive() public returns (bool) {

        if (tiers[PRE_ICO_ID].endTime <= now) {

            if (soldTokens < tiers[PRE_ICO_ID].maxAmount) {

                Tier storage preICOTier = tiers[PRE_ICO_ID];



                for (uint i = PRE_ICO_ID.add(1); i < tiers.length; i++) {

                    Tier storage icoTier = tiers[i];

                    icoTier.maxAmount = icoTier.maxAmount.add(preICOTier.maxAmount.sub(soldTokens));

                }



                preICOTier.maxAmount = soldTokens;

            }



            return false;

        }



        return tiers[PRE_ICO_ID].startTime <= now && soldTokens < tiers[PRE_ICO_ID].maxAmount;

    }



    function isICOFinished() public returns (bool) {

        if (maxTokenSupply > uint256(0) && soldTokens == maxTokenSupply) {

            return true;

        }


        return false;

    }



    function mint(address _address, uint256 _tokenAmount) public onlyOwner returns (uint256) {

        if (!isICOFinished()) {

            return mintInternal(_address, _tokenAmount);

        }



        return 0;

    }



    function __callback(bytes32, string _result, bytes) public {

        require(msg.sender == oraclize_cbAddress());

        uint256 result = parseInt(_result, 5);

        uint256 newPrice = uint256(10 ** 23).div(result);
        // uint256 etherPriceInUSD;    
        require(newPrice > 0);

        //not update when increasing/decreasing in 3 times

        if (result.div(3) < etherPriceInUSD || result.mul(3) > etherPriceInUSD) {

            etherPriceInUSD = result;



           emit  NewAutobayPriceTicker(_result);

        }

    }



    function transferEthers() internal {

        etherHolder.transfer(address(this).balance);

    }



    function update() internal {

        if (oraclize_getPrice("URL") > address(this).balance) {

            emit NewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");

        } else {

            emit NewOraclizeQuery("Oraclize query was sent, standing by for the answer..");

            oraclize_query("URL", "json(https://api.kraken.com/0/public/Ticker?pair=ETHUSD).result.XETHZUSD.c.0");

        }

    }



    function mintInternal(address _address, uint256 _tokenAmount) internal returns (uint256) {

        if (autobay.balanceOf(_address) == 0) {

            investors.push(_address);

        }

        uint256 mintedAmount = autobay.mint(_address, _tokenAmount);



        require(mintedAmount == _tokenAmount);



        soldTokens = soldTokens.add(_tokenAmount);

        if (maxTokenSupply > 0) {

            require(maxTokenSupply >= soldTokens);

        }



        return _tokenAmount;

    }




}