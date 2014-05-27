package com.finegamedesign.templeofgold
{
    import flash.display.DisplayObject;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    public class Model
    {
        internal static var levelScores:Array = [];
        internal static var score:int = 0;
        internal static var seconds:int = 60;
        internal static var locks:Array = "abcd".split("");
        internal static var keys:Array = "ABCD".split("");
        internal static var items:Object = {
            "@":	"Player",
            " ":    "Wall",
            ".":	"Floor",
            "$":	"Gold",
            "%":	"Stairs"
            // A-Z	key
            // a-z	corresponding lock
        };

        [Embed(source="levels.txt", mimeType="application/octet-stream")]
        private static var levelDiagramsClass:Class
        private static var levelDiagrams:Array = paragraphs(String(new levelDiagramsClass()));
        internal static function get levelCount():int
        {
            return levelDiagrams.length;
        }

        private static function parse(map:String):Array
        {
             var rows:Array = map.split("\n");
             for (var r:int = rows.length - 1; 0 <= r; r--) {
                 if (rows[r] == "") {
                     rows.splice(r, 1);
                 }
                 else {
                     rows[r] = rows[r].replace("\n", "");
                     rows[r] = rows[r].split("");
                 }
             }
             return rows;
        }

        internal static function paragraphs(levelDiagramsText:String):Array
        {
            return levelDiagramsText.split("\r\n").join("\n").split("\r").join("\n").split("\n\n");
        }

        public static function shuffle(array:Array):void
        {
            for (var i:int = array.length - 1; 1 <= i; i--) {
                var j:int = (i + 1) * Math.random();
                var tmp:* = array[i];
                array[i] = array[j];
                array[j] = tmp;
            }
        }

        internal var carryingIndex:int;
        internal var droppingIndex:int;
        internal var fuel:int;
        internal var highScore:int;
        internal var level:int;
        internal var levelScore:int;
        internal var map:Array;
        internal var moved:Boolean;
        internal var point:int;
        internal var playerRow:int;
        internal var playerColumn:int;
        internal var secondsRemaining:int;

        public function Model()
        {
            score = 0;
            highScore = 0;
            levelScores = [];
        }

        internal function populate(level:int):void
        {
            this.level = level;
            if (null == levelScores[level]) {
                levelScores[level] = 0;
            }
            levelScore = 0;
            point = 0;
            moved = false;
            fuel = 2000;
            carryingIndex = -1;
            droppingIndex = -1;
            map = parse(levelDiagrams[level - 1]);
            for (var r:int = 0; r < map.length; r++) {
                for (var c:int = 0; c < map[r].length; c++) {
                    if ("Player" == items[map[r][c]]) {
                        playerRow = r;
                        playerColumn = c;
                    }
                }
            }
        }

        internal function clear():void
        {
        }

        internal function update(secondsRemaining:int):int
        {
            this.secondsRemaining = secondsRemaining;
            return win();
        }

        internal function answer(direction:String):Boolean
        {
            var nextColumn:int = playerColumn;
            var nextRow:int = playerRow;
            if ("LEFT" == direction) {
                nextColumn--;
            }
            else if ("RIGHT" == direction) {
                nextColumn++;
            }
            else if ("UP" == direction) {
                nextRow--;
            }
            else if ("DOWN" == direction) {
                nextRow++;
            }
            if (blocked(nextRow, nextColumn)) {
                return false;
            }
            var key:String = map[nextRow][nextColumn];
            playerRow = nextRow;
            playerColumn = nextColumn;
            moved = true;
            fuel -= 10;
            var keyIndex:int = keys.indexOf(key);
            var lockIndex:int = locks.indexOf(key);
            droppingIndex = -1;
            if ("Stairs" == items[key]) {
                point = secondsRemaining + fuel;
                levelScore += point;
            }
            else if ("Gold" == items[key]) {
                map[playerRow][playerColumn] = ".";
                point = 100;
                levelScore += point;
                return true;
            }
            else if (0 <= keyIndex) {
                if (0 <= carryingIndex) {
                    droppingIndex = carryingIndex;
                    map[playerRow][playerColumn] =
                        keys[carryingIndex];
                }
                carryingIndex = keyIndex;
            }
            else if (0 <= lockIndex) {
                if (carryingIndex == lockIndex) {
                    droppingIndex = carryingIndex;
                    map[playerRow][playerColumn] = ".";
                        
                }
                carryingIndex = -1;
            }

            return false;
        }

        private function blocked(nextRow:int, nextColumn:int):Boolean {
            if (nextRow < 0 || map.length <= nextRow
             || nextColumn < 0 || map[nextRow].length <= nextColumn) {
                return true;
            }
            var key:String = map[nextRow][nextColumn];
            if ("Wall" == items[key]) {
                return true;
            }
            var lockIndex:int = locks.indexOf(key);
            if (0 <= lockIndex) {
                if (carryingIndex != lockIndex) {
                    return true;
                }
            }
            return false;
        }

        internal function at(c:int, r:int):String
        {
            return (r * 100 + c).toString();
        }

        internal function on():String
        {
            return items[map[playerRow][playerColumn]];
        }

        /**
         * @return  0 continue, 1: win, -1: lose.
         */
        private function win():int
        {
            var winning:int = 0;
            if (secondsRemaining <= 0 || fuel <= 0) {
                winning = -1;
            }
            else if ("Stairs" == on()) {
                winning = 1;
            }
            updateScore();
            return winning;
        }

        private function updateScore():int
        {
            if (levelScores[level] < levelScore) {
                levelScores[level] = levelScore;
            }
            var sum:int = 0;
            for each (var n:int in levelScores) {
                sum += n;
            }
            score = sum;
            return sum;
        }
    }
}
