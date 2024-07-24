import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  namespace: "app",
  enums: {
    Direction: [
      "Up",
      "Down",
      "Left",
      "Right"
    ]
  },
  tables: {
    PlayerPosition: {
      schema: {
        player: "address",
        x: "int32",
        y: "int32",
        isDead: "bool",
      },
      key: ["player"]
    }
  }
});
