// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";
import { PlayerPosition, PlayerPositionData, CoinPosition, PlayerCoins } from "../codegen/index.sol";
import { Direction } from "../codegen/common.sol";
import { getKeysWithValue } from "@latticexyz/world-modules/src/modules/keyswithvalue/getKeysWithValue.sol";

import { EncodedLengths, EncodedLengthsLib } from "@latticexyz/store/src/EncodedLengths.sol";

contract MyGameSystem is System {
  function generateCoins() public {
    CoinPosition.set(1, 1, true);
    CoinPosition.set(2, 2, true);
    CoinPosition.set(2, 3, true);
  }

  function spawn(int32 x, int32 y) public {
    address player = _msgSender();
    PlayerPosition.set(player, x, y);
  }

  function move(Direction direction) public {
    address player = _msgSender();
    PlayerPositionData memory playerPosition = PlayerPosition.get(player);

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

    PlayerPosition.set(player, x, y);

    if(CoinPosition.getExists(x, y))
    {
      CoinPosition.set(x, y, false);
      PlayerCoins.set(player, PlayerCoins.getAmount(player)+1);
    }
  }
}
