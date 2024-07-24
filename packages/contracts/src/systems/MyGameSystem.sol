// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";
import { PlayerPosition, PlayerPositionData, CoinPosition, PlayerCoins } from "../codegen/index.sol";
import { Direction } from "../codegen/common.sol";
import { getKeysWithValue } from "@latticexyz/world-modules/src/modules/keyswithvalue/getKeysWithValue.sol";

import { EncodedLengths, EncodedLengthsLib } from "@latticexyz/store/src/EncodedLengths.sol";

interface ICircomVerifier {
    function verifyProof(uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[4] calldata _pubSignals) external view returns (bool);
}

contract MyGameSystem is System {
  function generateCoins() public {
    CoinPosition.set(1, 1, true);
    CoinPosition.set(2, 2, true);
    CoinPosition.set(2, 3, true);
  }

  function spawn(int32 x, int32 y) public {
    address player = _msgSender();
    PlayerPosition.set(player, x, y, false);
  }

  function move(Direction direction) public {
    address player = _msgSender();
    PlayerPositionData memory playerPosition = PlayerPosition.get(player);

    require(!playerPosition.isDead, "Player is dead");

    int32 x = playerPosition.x;
    int32 y = playerPosition.y;

    if(direction == Direction.Up)
      y-=1;
    if(direction == Direction.Down)
      y+=1;
    if(direction == Direction.Left)
      x-=1;
    if(direction == Direction.Right)
      x+=1;

    PlayerPosition.setX(player, x);
    PlayerPosition.setY(player, y);

    if(CoinPosition.getExists(x, y))
    {
      CoinPosition.set(x, y, false);
      PlayerCoins.set(player, PlayerCoins.getAmount(player)+1);
    }
  }

  function detonateBomb(uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[4] calldata _pubSignals, address playerAddress) public {
    //ICircomVerifier(0x9A676e781A523b5d0C0e43731313A708CB607508).verifyProof(_pA, _pB, _pC, _pubSignals);
    uint32 commitment = uint32(_pubSignals[0]);
    uint32 result = uint32(_pubSignals[1]);
    int32 guessX = int32(uint32(uint(_pubSignals[2])));
    int32 guessY = int32(uint32(uint(_pubSignals[3])));

    PlayerPositionData memory playerPosition = PlayerPosition.get(playerAddress);

    require(result == 1, "No bomb in this position");
    require(playerPosition.x == guessX && playerPosition.y == guessY, "Invalid position");
    
    //uint32 secretCommitment = SecretCommitment.get();
    //require(uint32(uint(commitment)) == secretCommitment, "Invalid commitment");

    PlayerPosition.setIsDead(playerAddress, true);
  }
}
