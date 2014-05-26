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
        internal static var items:Object = {
            "@":	"Player",
            " ":    "Wall",
            // A-Z	key
            // a-z	corresponding lock
            ".":	"Floor",
            "$":	"Gold",
            "%":	"Stairs"
        };
        /*
            @	player
            " "	(space) wall
            A-Z	key
            a-z	corresponding lock
            .	Floor
            $	gold
            %	stairs down
         */
        [Embed(source="levels.txt", mimeType="application/octet-stream")]
        private static var levelDiagramsClass:Class
        private static var levelDiagrams:Array = paragraphs(String(new levelDiagramsClass()));

        private static function parse(map:String):Array
        {
             var rows:Array = map.split("\n");
             for (var r:int = 0; r < rows.length; r++) {
                 rows[r] = rows[r].split("");
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

        internal var highScore:int;
        internal var level:int;
        internal var levelScore:int;
        internal var map:Array;
        internal var point:int;
        internal var playerRow:int;
        internal var playerColumn:int;

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
            point = 0;
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
            return win(secondsRemaining);
        }

        internal function answer(direction:String):Boolean
        {
            if ("LEFT" == direction) {
                playerColumn--;
            }
            else if ("RIGHT" == direction) {
                playerColumn++;
            }
            else if ("UP" == direction) {
                playerRow--;
            }
            else if ("DOWN" == direction) {
                playerRow++;
            }
            return false;
        }

        /**
         * @return  0 continue, 1: win, -1: lose.
         */
        private function win(secondsRemaining:int):int
        {
            updateScore();
            var winning:int = 0;
            if (secondsRemaining <= 0) {
                winning = -1;
            }
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
