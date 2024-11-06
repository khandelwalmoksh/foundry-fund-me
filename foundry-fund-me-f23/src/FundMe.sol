// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";


error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    mapping(address => uint256) private s_addresstoamountFunded;  //private variables are more gas efficient
    address[] public s_funders;

    address private immutable i_owner;
    uint256 public constant MINIMUM_USD = 5e18;
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable {
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "Don't sent enough ETH");
        s_addresstoamountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function cheaperWithdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length;
        fundersLength;
        for (
            uint256 funderIndex = 0;funderIndex < s_funders.length;funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addresstoamountFunded[funder] = 0;
    }     
       s_funders = new address[](0);
       (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }


    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;funderIndex < s_funders.length;funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addresstoamountFunded[funder] = 0;
        }
        s_funders = new address[](0);

        //call
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "Call failed");
    }

    modifier onlyOwner() {
        //require(msg.sender == i_owner ,"sender is not owner");
        if (msg.sender != i_owner) {     //!= : Not equals to 
            revert FundMe__NotOwner();       //can revert function call in middle of function
        }
        _;
    }

    /**
     * View/Pure functions (Getters)
     */

    function getAddressToAmountFunded(address fundingAddress) external view returns(uint256) {
        return s_addresstoamountFunded[fundingAddress];
    }
    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }
    function getOwner() external view returns (address) {
        return i_owner;
    }
}