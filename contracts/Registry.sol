//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import '../interface/RegistryInterface.sol';
import "hardhat/console.sol";

contract Registry is Ownable, RegistryInterface {
    address public factory;
    
    mapping(address => mapping(address => address)) public getPair;

    address[] public allPairs;


    modifier onlyFactory() {
        require(factory == _msgSender(), "caller is not the Factory");
        _;
    }

    function setFactory(address _factory) external override onlyOwner {
        factory = _factory;
    }

    function setPair(
        address token0,
        address token1,
        address pairAddress
    ) external override onlyFactory {
        getPair[token0][token1] = pairAddress;
        getPair[token1][token0] = pairAddress; 
        allPairs.push(pairAddress);
    }


    function getAddressOfPair(address token0, address token1) external view override returns (address)
    {
        return getPair[token0][token1];
    }
}