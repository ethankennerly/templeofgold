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

        [Embed(source="levels.txt", mimeType="application/octet-stream")]
        internal static var levelDiagramsClass:Class
        internal static var levelDiagrams:Array = parse(String(new levelDiagramsClass()));

        internal static function parse(levelDiagramsText:String):Array
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
        internal var point:int;

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
