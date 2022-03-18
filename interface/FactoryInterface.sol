//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface FactoryInterface {
    function setRouter(address _router) external ;
    function setRegistry(address _registry) external;
    function setFeeContract(address _feeContract) external;
    function createPair(address tokenA, address tokenB) external returns (address);

}