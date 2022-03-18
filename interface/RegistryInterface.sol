//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface RegistryInterface {
    function getAddressOfPair(address token0, address token1) external returns (address);
    function setFactory(address _fabric) external;
    function setPair(address token0, address token1, address pairAddress) external;
}