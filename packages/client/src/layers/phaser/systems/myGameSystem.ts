import { Has, defineEnterSystem, defineSystem, defineExitSystem, getComponentValueStrict } from "@latticexyz/recs";
import { PhaserLayer } from "../createPhaserLayer";
import { 
  pixelCoordToTileCoord,
  tileCoordToPixelCoord
} from "@latticexyz/phaserx";
import { TILE_WIDTH, TILE_HEIGHT, Animations, Directions } from "../constants";

function decodeHexString(hexString: string): [number, number] {
  const cleanHex = hexString.slice(2);
  const firstHalf = cleanHex.slice(0, cleanHex.length / 2);
  const secondHalf = cleanHex.slice(cleanHex.length / 2);
  return [parseInt(firstHalf, 16), parseInt(secondHalf, 16)];
}

function to20ByteAddress(fullAddress: string): string {
    const shortAddress = '0x' + fullAddress.slice(26);
    return shortAddress;
}

export const createMyGameSystem = (layer: PhaserLayer) => {
  const {
    world,
    networkLayer: {
      components: {
        Player
      },
      systemCalls: {
        spawn,
        move,
        detonateBomb
      }
    },
    scenes: {
        Main: {
            objectPool,
            input
        }
    }
  } = layer;

  input.pointerdown$.subscribe((event) => {
    const x = event.pointer.worldX;
    const y = event.pointer.worldY;
    const player = pixelCoordToTileCoord({ x, y }, TILE_WIDTH, TILE_HEIGHT);
    if(player.x == 0 && player.y == 0)
        return;
    spawn(player.x, player.y) 
  });

  input.onKeyPress((keys) => keys.has("W"), () => {
    move(Directions.UP);
  });

  input.onKeyPress((keys) => keys.has("S"), () => {
    move(Directions.DOWN);
  });

  input.onKeyPress((keys) => keys.has("A"), () => {
    move(Directions.LEFT);
  });

  input.onKeyPress((keys) => keys.has("D"), () => {
    move(Directions.RIGHT);
  });

  input.onKeyPress((keys) => keys.has("I"), () => {
    //generateCoins();
  });

  defineEnterSystem(world, [Has(Player)], ({entity}) => {
    const playerObj = objectPool.get(entity, "Sprite");
    playerObj.setComponent({
        id: 'animation',
        once: (sprite) => {
            sprite.play(Animations.Player);
        }
    })
  });

  defineSystem(world, [Has(Player)], ({ entity }) => {
    const player = getComponentValueStrict(Player, entity);
    const pixelPosition = tileCoordToPixelCoord(player, TILE_WIDTH, TILE_HEIGHT);

    const playerObj = objectPool.get(entity, "Sprite");


    if(!player.isDead)
    {
        detonateBomb(pixelPosition.x/32, pixelPosition.y/32, to20ByteAddress(entity));
    }else
    {
        playerObj.setComponent({
            id: 'animation',
            once: (sprite) => {
              sprite.play(Animations.Dead);
            }
        })
    }


    playerObj.setComponent({
      id: "position",
      once: (sprite) => {
        sprite.setPosition(pixelPosition.x, pixelPosition.y);
      }
    })
  })
};
